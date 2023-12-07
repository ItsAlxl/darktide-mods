local mod = get_mod("PanicStimm")

local STIMM_SLOT_NAME = "slot_pocketable_small"

local AUTO_STIMM_STAGES = {
    NONE = 0,
    SWITCH_TO = 1,
    CANCEL_RMB = 2,
    INJECT = 3,
    SWITCH_BACK = 4,
}

local auto_stimm_stage = 0

local current_wield_slot = nil
local unwield_to_slot = nil

local after_request_type = nil
local input_request = nil

mod.on_setting_changed = function(id)
    if id == "after_inject" then
        after_request_type = mod:get(id)
        if after_request_type == "" then
            after_request_type = nil
        end
    end
end
mod.on_setting_changed("after_inject")

local _get_player_unit = function()
    local plr = Managers.player and Managers.player:local_player_safe(1)
    return plr and plr.player_unit
end

mod._quick_inject = function()
    if auto_stimm_stage ~= AUTO_STIMM_STAGES.NONE then
        auto_stimm_stage = AUTO_STIMM_STAGES.NONE
        input_request = nil
        return
    end

    local plr_unit = _get_player_unit()
    local unit_data_extension = plr_unit and ScriptUnit.extension(plr_unit, "unit_data_system")
    local inventory_component = unit_data_extension and unit_data_extension:read_component("inventory")
    local pocketable_name = inventory_component and inventory_component[STIMM_SLOT_NAME]
    if pocketable_name and pocketable_name ~= "not_equipped" then
        auto_stimm_stage = current_wield_slot == STIMM_SLOT_NAME and AUTO_STIMM_STAGES.CANCEL_RMB or AUTO_STIMM_STAGES.SWITCH_TO
    end
end

mod:hook_safe(CLASS.PlayerUnitWeaponExtension, "on_slot_wielded", function(self, slot_name, ...)
    if self._player == Managers.player:local_player(1) then
        current_wield_slot = slot_name
        if auto_stimm_stage == AUTO_STIMM_STAGES.SWITCH_BACK then
            if input_request and (not unwield_to_slot or slot_name == unwield_to_slot) then
                auto_stimm_stage = AUTO_STIMM_STAGES.NONE
                input_request = nil
            end
        else
            auto_stimm_stage = auto_stimm_stage == AUTO_STIMM_STAGES.SWITCH_TO and slot_name == STIMM_SLOT_NAME and AUTO_STIMM_STAGES.CANCEL_RMB or AUTO_STIMM_STAGES.NONE
        end
    end
end)

mod:hook_safe(CLASS.ActionHandler, "start_action", function(self, id, action_objects, action_name, action_params, action_settings, used_input, ...)
    if _get_player_unit() == self._unit then
        if auto_stimm_stage == AUTO_STIMM_STAGES.SWITCH_BACK and (action_name == "action_unwield_to_previous" or action_name == "action_wield") and used_input ~= "quick_wield" then
            input_request = after_request_type == "PREVIOUS" and
                (unwield_to_slot == "slot_secondary" and "wield_2"
                    or unwield_to_slot == "slot_grenade_ability" and "grenade_ability_pressed"
                    or "wield_1")
                or after_request_type
            unwield_to_slot = input_request == "wield_1" and "slot_primary"
                or input_request == "wield_2" and "slot_secondary"
                or input_request == "grenade_ability_pressed" and "slot_grenade_ability"
                or nil
        elseif action_name == "action_wield" then
            local slot_name = self._inventory_component.wielded_slot
            unwield_to_slot = slot_name ~= STIMM_SLOT_NAME and slot_name or unwield_to_slot
        elseif auto_stimm_stage == AUTO_STIMM_STAGES.INJECT and (action_name == "action_flair" or action_name == "action_use_self") then
            auto_stimm_stage = AUTO_STIMM_STAGES.SWITCH_BACK
        end
    end
end)

local _input_action_hook = function(func, self, action_name)
    local val = func(self, action_name)
    if action_name == "action_two_hold" and auto_stimm_stage >= AUTO_STIMM_STAGES.CANCEL_RMB then
        return false
    end
    if auto_stimm_stage == AUTO_STIMM_STAGES.CANCEL_RMB and action_name == "action_two_release" then
        auto_stimm_stage = AUTO_STIMM_STAGES.INJECT
        return true
    end
    return input_request and action_name == input_request
        or auto_stimm_stage == AUTO_STIMM_STAGES.SWITCH_TO and action_name == "wield_4"
        or auto_stimm_stage == AUTO_STIMM_STAGES.INJECT and action_name == "action_one_pressed"
        or val
end
mod:hook(CLASS.InputService, "_get", _input_action_hook)
mod:hook(CLASS.InputService, "_get_simulate", _input_action_hook)
