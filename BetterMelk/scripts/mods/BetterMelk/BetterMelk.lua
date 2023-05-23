local mod = get_mod("BetterMelk")
local PlayerProgressionUnlocks = require("scripts/settings/player/player_progression_unlocks")

local _no_progress = function(tasks)
    for _, task in pairs(tasks) do
        if task.criteria.value > 0 then
            return false
        end
    end
    return true
end

local _notify = function(msg)
    local mode = mod:get("notif_mode")
    if mode == 0 or mode == 1 then
        mod:echo(mod:localize(msg))
    end
    if mode == 0 or mode == 2 then
        mod:notify(mod:localize(msg))
    end
end

local _auto_melk = function(profile, allow_notif)
    if profile.current_level < PlayerProgressionUnlocks.contracts then
        return
    end
    local character_id = profile.character_id
    local interface = Managers.data_service.contracts._backend_interface.contracts
    local promise = interface:get_current_contract(character_id)
    if promise then
        promise:next(function(contract_data)
            if allow_notif and mod:get("notify_new") and _no_progress(contract_data.tasks) then
                _notify("msg_new")
            end
            if contract_data.fulfilled and not contract_data.rewarded then
                if allow_notif and mod:get("notify_done") then
                    _notify("msg_done")
                end
                interface:complete_contract(character_id)
            end
        end)
    elseif allow_notif then
        mod:error("msg_error")
    end
end

mod:hook_safe("GameplayStateRun", "on_enter", function(...)
    if Managers.state and Managers.state.game_mode and Managers.state.game_mode:game_mode_name() == "hub" then
        _auto_melk(Managers.player:local_player(1):profile(), true)
    end
end)

mod:hook_safe("MainMenuView", "_set_player_profile_information", function(self, profile, ...)
    _auto_melk(profile)
end)
