local mod = get_mod("BetterMelk")

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

local _auto_melk = function(character_id, allow_notif)
    Managers.backend.interfaces.contracts:get_current_contract(character_id):next(function(contract_data)
        if allow_notif and mod:get("notify_new") and _no_progress(contract_data.tasks) then
            _notify("msg_new")
        end
        if contract_data.fulfilled and not contract_data.rewarded then
            if allow_notif and mod:get("notify_done") then
                _notify("msg_done")
            end
            Managers.backend.interfaces.contracts:complete_contract(character_id)
        end
    end)
end

mod:hook_safe("GameModeManager", "init", function(self, game_mode_context, game_mode_name, ...)
    if game_mode_name == "hub" then
        _auto_melk(Managers.player:local_player(1):character_id(), true)
    end
end)

mod:hook_safe("MainMenuView", "_set_player_profile_information", function(self, profile, ...)
    _auto_melk(profile.character_id)
end)
