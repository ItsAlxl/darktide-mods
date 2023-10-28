local mod = get_mod("AfterGrenade")

local request = nil
local after_request_type = nil
local last_equipped_slot = nil

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
            elseif plr_class == "psyker_2" then
                after_request_type = mod:get("ag_psyker")
            end

            if after_request_type == "" then
                after_request_type = nil
            end
        end
    end
end

local _input_action_hook = function(func, self, action_name)
    local val = func(self, action_name)

    if action_name == request then
        request = nil
        val = true
    end

    return val
end
mod:hook(CLASS.InputService, "_get", _input_action_hook)
mod:hook(CLASS.InputService, "_get_simulate", _input_action_hook)

mod:hook_safe(CLASS.ActionHandler, "start_action", function(self, id, action_objects, action_name, action_params, action_settings, used_input, ...)
    if after_request_type then
        local slot = self._inventory_component.wielded_slot
        if action_name == "action_wield" then
            if slot ~= "slot_grenade_ability" then
                last_equipped_slot = slot
            end
        elseif slot == "slot_grenade_ability" and
        ((action_name == "action_unwield" and used_input == "quick_wield") or action_name == "action_unwield_to_previous") then
            if after_request_type == "PREVIOUS" then
                if last_equipped_slot == "slot_secondary" then
                    request = "wield_2"
                else
                    request = "wield_1"
                end
            else
                request = after_request_type
            end
        end
    end
end)

mod:hook_safe(CLASS.GameModeManager, "init", function(self, game_mode_context, game_mode_name, ...)
    if game_mode_name ~= "hub" then
        _update_request_type()
    end
end)

mod.on_setting_changed = function(id)
    _update_request_type()
end
