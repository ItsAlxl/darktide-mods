local mod = get_mod("AfterGrenade")

local prev_action = nil
local request = nil
local after_request_type = nil

local _update_request_type = function()
    if Managers and Managers.player then
        local player = Managers.player:local_player(1)
        if player and player._profile and player._profile.specialization then
            local plr_class = player._profile.specialization

            if plr_class == "zealot_2" then
                after_request_type = mod:get("ag_zealot")
            elseif plr_class == "veteran_2" then
                after_request_type = mod:get("ag_veteran")
            elseif plr_class == "ogryn_2" then
                after_request_type = mod:get("ag_ogryn")
            end
            
            if after_request_type == "" then
                after_request_type = nil
            end
        end
    end
end

mod:hook("InputService", "get", function(func, self, action_name)
    local val = func(self, action_name)

    if action_name == request then
        request = nil
        val = true
    end

    return val
end)

mod:hook_safe("ActionHandler", "start_action", function(self, id, action_objects, action_name, ...)
    if after_request_type then
        if action_name == "action_unwield_to_previous" and (prev_action == "action_throw_grenade" or prev_action == "action_underhand_throw_grenade") then
            request = after_request_type
        end
        prev_action = action_name
    end
end)

mod:hook_safe("GameModeManager", "init", function(self, game_mode_context, game_mode_name, ...)
    if game_mode_name == "hub" then
        _update_request_type()
    end
end)

mod.on_setting_changed = function(id)
    _update_request_type()
end
