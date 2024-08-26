local mod = get_mod("BornReady")

mod.leave_party = function ()
    Managers.party_immaterium:leave_party()
end

mod._kb_leave_party = function()
    if not Managers.ui:chat_using_input() then
        mod.leave_party()
    end
end

-- Automatically skip end screen

local eom_time = nil
local chat_cancels_eom_skip = nil

mod.cancel_eom_skip = function (silent)
    if eom_time then
        if not silent then
            mod:notify(mod:localize("msg_eom_cancel"))
        end
        eom_time = nil
    end
end

mod._kb_cancel_eom_skip = function()
    if not Managers.ui:chat_using_input() then
        mod.cancel_eom_skip()
    end
end

mod.skip_eom = function()
    if Managers.ui:view_active("end_view") then
        eom_time = nil
        Managers.multiplayer_session:leave("skip_end_of_round")
    end
end

mod._kb_skip_eom = function ()
    if not Managers.ui:chat_using_input() then
        mod.skip_eom()
    end
end

mod:hook_safe(CLASS.EndView, "on_enter", function(...)
    chat_cancels_eom_skip = mod:get("eom_cancel_chat")
    if mod:get("autoskip") then
        if chat_cancels_eom_skip and Managers.ui:chat_using_input() then
            mod.cancel_eom_skip()
        else
            eom_time = mod:get("end_skip_time")
        end
    else
        eom_time = nil
    end
end)

mod:hook_safe(CLASS.EndView, "update", function(self, dt, ...)
    if eom_time then
        if chat_cancels_eom_skip and Managers.ui:chat_using_input() then
            mod.cancel_eom_skip()
        else
            eom_time = eom_time - dt
            if eom_time <= 0 then
                mod.skip_eom()
            end
        end
    end
end)

-- Automatically ready up in lobbies
mod:hook_safe(CLASS.LobbyView, "on_enter", function(self)
    if mod:get("autoready") then
        self:_set_own_player_ready_status(true)
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
