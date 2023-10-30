local mod = get_mod("FullAuto")

local NATURAL_MODE = {
    fullauto = 1,
    chargeup = 2
}
mod.NATURAL_MODE = NATURAL_MODE
local CHARGEUP_SHOT_STAGE = {
    holding = 1,
    release = 2,
    repress = 3
}

local STANDARD_MULTIPLIER = 0.5
local SPRINT_MULTIPLIER = 1.1

local select_autofire = mod:get("default_autofire")

local track_autofire = nil
local autofire_delay_normal = nil
local autofire_delay_aim = nil

local track_natural = nil
local natural_autofire_normal = nil
local natural_autofire_aim = nil

local autofire_delay_current = nil
local natural_current = nil

local is_firing = false
local shoot_for_me = mod:get("shoot_for_me")
local next_autofire = -1.0
local chargeup_stage = CHARGEUP_SHOT_STAGE.holding

local include_psyker_bees = mod:get("include_psyker_bees")
local chargeup_autofire = mod:get("chargeup_autofire")

local time_scale = 1.0
local is_sprinting = false

mod:io_dofile("FullAuto/scripts/mods/FullAuto/CreateUI")
mod:io_dofile("FullAuto/scripts/mods/FullAuto/WeaponValidator")

mod.on_setting_changed = function(id)
    if id == "hud_element" then
        local firemode_element = mod.get_hud_element()
        if firemode_element then
            firemode_element:update_vis(mod:get(id))
        end
    elseif id == "include_psyker_bees" then
        include_psyker_bees = mod:get(id)
    elseif id == "shoot_for_me" then
        shoot_for_me = mod:get(id)
    elseif id == "chargeup_autofire" then
        chargeup_autofire = mod:get(id)
    end
end

local _disable_autofire = function()
    track_autofire = nil
    autofire_delay_normal = nil
    autofire_delay_aim = nil

    track_natural = nil
    natural_autofire_normal = nil
    natural_autofire_aim = nil

    autofire_delay_current = nil
    natural_current = nil
    is_firing = false
    next_autofire = -1
    chargeup_stage = CHARGEUP_SHOT_STAGE.holding
end

mod:hook_safe(CLASS.PlayerUnitWeaponExtension, "on_slot_wielded", function(self, slot_name, ...)
    if self._player == Managers.player:local_player(1) then
        _disable_autofire()
        autofire_delay_normal, autofire_delay_aim, natural_autofire_normal, natural_autofire_aim = mod.get_weapon_data(self._weapons[slot_name].weapon_template, include_psyker_bees)

        track_autofire = (autofire_delay_normal or autofire_delay_aim) and true or false
        autofire_delay_current = autofire_delay_normal

        track_natural = (natural_autofire_normal or natural_autofire_aim) and true or false
        natural_current = natural_autofire_normal
    end
end)

local _set_firemode_selection = function(asf)
    select_autofire = asf

    local firemode_element = mod.get_hud_element()
    if firemode_element then
        firemode_element:update_firemode(select_autofire)
    end
end

mod.is_in_autofire_mode = function()
    return select_autofire
end

mod._toggle_select = function(held)
    _set_firemode_selection(not select_autofire)
end

mod:hook_safe(CLASS.GameModeManager, "init", function(self, game_mode_context, game_mode_name, ...)
    if game_mode_name ~= "hub" then
        _set_firemode_selection(mod:get("default_autofire"))
    end
end)

local _get_player_unit = function()
    local plr = Managers.player and Managers.player:local_player(1)
    return plr and plr.player_unit
end

mod:hook_safe(CLASS.ActionHandler, "start_action", function(self, id, ...)
    if _get_player_unit() == self._unit then
        if id == "weapon_action" then
            time_scale = self._registered_components[id].component.time_scale
        end
    end
end)

mod:hook_require("scripts/extension_systems/character_state_machine/character_states/utilities/sprint", function(Sprint)
    mod:hook_safe(Sprint, "sprint_input", function(input_source, sprinting, ...)
        if is_sprinting ~= sprinting then
            is_sprinting = sprinting
        end
    end)
end)

local _begin_aim = function()
    autofire_delay_current = autofire_delay_aim
    natural_current = natural_autofire_aim
end

local _end_aim = function()
    autofire_delay_current = autofire_delay_normal
    natural_current = natural_autofire_normal
end

mod:hook_require("scripts/utilities/alternate_fire", function(AlternateFire)
    mod:hook_safe(AlternateFire, "start", function(alternate_fire_component, weapon_tweak_templates_component, spread_control_component, sway_control_component, sway_component, movement_state_component, peeking_component, first_person_extension, animation_extension, weapon_extension, weapon_template, player_unit, ...)
        if player_unit == _get_player_unit() then
            _begin_aim()
        end
    end)

    mod:hook_safe(AlternateFire, "stop", function(alternate_fire_component, peeking_component, first_person_extension, weapon_tweak_templates_component, animation_extension, weapon_template, skip_stop_anim, player_unit, ...)
        if player_unit == _get_player_unit() then
            _end_aim()
        end
    end)
end)

mod:hook_safe(CLASS.WarpChargeActionModule, "start", function(self, ...)
    if self._player_unit == _get_player_unit() then
        _begin_aim()
    end
end)

mod:hook_safe(CLASS.WarpChargeActionModule, "finish", function(self, ...)
    if self._player_unit == _get_player_unit() then
        _end_aim()
    end
end)

mod:hook_safe(CLASS.ChargeActionModule, "start", function(self, ...)
    if chargeup_stage == CHARGEUP_SHOT_STAGE.repress and self._player_unit == _get_player_unit() then
        chargeup_stage = CHARGEUP_SHOT_STAGE.holding
    end
end)

mod:hook_safe(CLASS.ChargeActionModule, "fixed_update", function(self, ...)
    if chargeup_autofire and natural_current == NATURAL_MODE.chargeup and chargeup_stage == CHARGEUP_SHOT_STAGE.holding and self._player_unit == _get_player_unit() then
        local charge_level = self._action_module_charge_component.charge_level
        local charge_template = self._weapon_extension:charge_template()
        local fully_charged_charge_level = charge_template.fully_charged_charge_level or 1

        if charge_level >= fully_charged_charge_level then
            chargeup_stage = CHARGEUP_SHOT_STAGE.release
        end
    end
end)

local _input_action_hook = function(func, self, action_name)
    local val = func(self, action_name)
    if track_autofire or (track_natural and (shoot_for_me or natural_current == NATURAL_MODE.chargeup)) then
        local is_lmb_action = action_name == "action_one_pressed"

        -- first, determine if we're holding down LMB
        if val and not shoot_for_me then
            if is_lmb_action then
                is_firing = true
                next_autofire = -1
            end
            if action_name == "action_one_release" then
                is_firing = false
            end
        end

        if select_autofire then
            -- if this is attack is a charge-up (helbore, staffs) or already fully-auto
            if track_natural and natural_current then
                if action_name == "action_one_hold" then
                    -- just shoot, unless the chargeup is finished
                    if chargeup_stage == CHARGEUP_SHOT_STAGE.release then
                        chargeup_stage = CHARGEUP_SHOT_STAGE.repress
                        return false
                    end
                    return shoot_for_me or val
                end
                if is_lmb_action and natural_current == NATURAL_MODE.chargeup then
                    -- some attacks will require us to re-press LMB after firing a charge
                    if (is_firing or shoot_for_me) and chargeup_stage == CHARGEUP_SHOT_STAGE.repress then
                        return true
                    end
                    -- if we click during a chargeup, release it prematurely
                    if val then
                        chargeup_stage = CHARGEUP_SHOT_STAGE.release
                    end
                end
            elseif is_lmb_action and (is_firing or shoot_for_me) and autofire_delay_current then
                -- the original core of the mod; click every X seconds
                local this_t = Managers.time and Managers.time:time("main")
                if next_autofire < 0 or this_t >= next_autofire then
                    next_autofire = this_t + autofire_delay_current / time_scale * (is_sprinting and SPRINT_MULTIPLIER or STANDARD_MULTIPLIER)
                    return true
                end
                return false
            end
        end
    end

    return val
end
mod:hook(CLASS.InputService, "_get", _input_action_hook)
mod:hook(CLASS.InputService, "_get_simulate", _input_action_hook)
