local mod = get_mod("AfterGrenade")

local after_request_type = nil
local after_request_qs_type = nil

local last_equipped_slot = nil
local input_request = nil

local _update_request_type = function()
    if Managers and Managers.player then
        local player = Managers.player:local_player_safe(1)
        local plr_class = player and player._profile and player._profile.specialization

        after_request_type = nil
        after_request_qs_type = nil
        if plr_class == "zealot_2" then
            after_request_type = mod:get("ag_zealot")
            after_request_qs_type = mod:get("ag_zealot_quickswap")
        elseif plr_class == "veteran_2" then
            after_request_type = mod:get("ag_veteran")
            after_request_qs_type = mod:get("ag_veteran_quickswap")
        elseif plr_class == "ogryn_2" then
            after_request_type = mod:get("ag_ogryn")
            after_request_qs_type = mod:get("ag_ogryn_quickswap")
        elseif plr_class == "psyker_2" then
            after_request_type = nil
            after_request_qs_type = mod:get("ag_psyker_quickswap")
        end

        if after_request_type == "" then
            after_request_type = nil
        end
        if after_request_qs_type == "" then
            after_request_qs_type = nil
        end
    end
end

local _input_action_hook = function(func, self, action_name)
    local val = func(self, action_name)

    if action_name == input_request then
        input_request = nil
        val = true
    end

    return val
end
mod:hook(CLASS.InputService, "_get", _input_action_hook)
mod:hook(CLASS.InputService, "_get_simulate", _input_action_hook)

mod:hook_safe(CLASS.ActionHandler, "start_action", function(self, id, action_objects, action_name, action_params, action_settings, used_input, ...)
    if after_request_type or after_request_qs_type then
        local slot = self._inventory_component.wielded_slot
        if action_name == "action_wield" then
            if slot ~= "slot_grenade_ability" then
                last_equipped_slot = slot
            end
        elseif slot == "slot_grenade_ability" then
            input_request = nil
            if used_input == "quick_wield" then
                input_request = after_request_qs_type
            elseif action_name == "action_unwield_to_previous" then
                input_request = after_request_type
            end

            if input_request == "PREVIOUS" then
                input_request = last_equipped_slot == "slot_secondary" and "wield_2" or "wield_1"
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

_update_request_type()
