local mod = get_mod("EnlightenedGameEnjoyer")

mod:hook_safe(CLASS.PartyImmateriumManager, "update", function(self, ...)
    if self:is_in_matchmaking() then
        self:cancel_matchmaking()
    end
end)

mod:hook_safe(CLASS.PartyImmateriumManager, "_mission_matchmaking_aborted", function(...)
    mod:notify(mod:localize("msg_notif"))
end)
