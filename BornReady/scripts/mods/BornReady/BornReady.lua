local mod = get_mod("BornReady")

mod._leave_party = function()
    Managers.party_immaterium:leave_party()
end

-- Automatically ready up in lobbies
mod:hook_safe(CLASS.LobbyView, "on_enter", function(self)
    if mod:get("autoready") then
        self:_set_own_player_ready_status(true)
    end
end)

-- Automatically skip end screen
mod:hook_safe(CLASS.EndView, "on_enter", function(...)
    if mod:get("autoskip") then
        Managers.multiplayer_session:leave("skip_end_of_round")
    end
end)

-- Auto-accept votes to begin matchmaking (prevents the popup)
mod:hook_require("scripts/settings/voting/voting_templates/mission_vote_matchmaking_immaterium", function(matchmake_vote_template)
    mod:hook(matchmake_vote_template, "on_started", function(func, voting_id, ...)
        if mod:get("automatch") then
            Managers.voting:cast_vote(voting_id, "yes")
        else
            func(voting_id, ...)
        end
    end)
end)

-- Auto-accept/decline party invites (prevents the popup)
mod:hook(CLASS.PartyImmateriumManager, "_handle_immaterium_invite", function(func, self, party_id, invite_token, inviter_account_id)
    local auto = mod:get("autojoin")
    if auto == 0 then
        func(self, party_id, invite_token, inviter_account_id)
    else
        self:_close_invite_popup(party_id)
        if auto == 1 then
            self:join_party({
                party_id = party_id,
                invite_token = invite_token
            })
        else
            self:_decline_party_invite(party_id, invite_token)
        end
    end
end)

-- Auto-accept/decline party join requests (prevents the popup)
mod:hook(CLASS.PartyImmateriumManager, "_request_to_join_popup", function(func, self, joiner_account_id)
    local auto = mod:get("autowelcome")
    if auto == 0 then
        func(self, joiner_account_id)
    else
        self:_close_request_to_join_popup(joiner_account_id)
        Managers.grpc:answer_request_to_join(self:party_id(), joiner_account_id, auto == 1 and "OK_POPUP" or "MEMBER_DECLINED_REQUEST_TO_JOIN")
    end
end)
