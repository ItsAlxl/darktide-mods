local mod = get_mod("FullAuto")

local NATURAL_MODE = {
    fullauto = 1,
    chargeup = 2
}
mod.NATURAL_MODE = NATURAL_MODE
local CHARGEUP_SHOT_STAGE = {
    holding = 1,
    release = 2,
    repress = 3,
    delay = 4,
}

local STANDARD_MULTIPLIER = 0.5
local SPRINT_MULTIPLIER = 1.1

local select_autofire = true

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
local last_charge_level = 0.0
local chargeup_stage = CHARGEUP_SHOT_STAGE.holding

local remember_per_wep = mod:get("remember_per_wep")
local starting_default_autofire = mod:get("default_autofire")
local include_psyker_bees = mod:get("include_psyker_bees")
local chargeup_autofire = mod:get("chargeup_autofire")
local chargeup_amt = 0.01 * mod:get("chargeup_autofire_amt")

local time_scale = 1.0
local is_sprinting = false

local cached_default_autofires = {}
local wep_template_name = nil
local ignore_next_autofire_default = false
local shoot_charge_with_click = false

local delayed_warp_end = false

mod:io_dofile("FullAuto/scripts/mods/FullAuto/CreateUI")
mod:io_dofile("FullAuto/scripts/mods/FullAuto/WeaponValidator")

mod.on_setting_changed = function(id)
    if id == "hud_element" then
        local firemode_element = mod.get_hud_element()
        if firemode_element then
            firemode_element:set_enabled(mod:get(id))
        end
    elseif id == "hud_element_size" then
        local firemode_element = mod.get_hud_element()
        if firemode_element then
            firemode_element:set_side_length(mod:get(id))
        end
    elseif id == "remember_per_wep" then
        remember_per_wep = mod:get(id)
    elseif id == "default_autofire" then
        starting_default_autofire = mod:get(id)
    elseif id == "include_psyker_bees" then
        include_psyker_bees = mod:get(id)
    elseif id == "chargeup_autofire" then
        chargeup_autofire = mod:get(id)
    elseif id == "chargeup_autofire_amt" then
        chargeup_amt = 0.01 * mod:get(id)
    elseif id == "shoot_for_me" then
        shoot_for_me = mod:get(id)
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
    shoot_charge_with_click = false
    delayed_warp_end = false

    next_autofire = -1
    chargeup_stage = CHARGEUP_SHOT_STAGE.holding
    last_charge_level = 0.0
end

mod.set_weapon_default = function(template_name, default_autofire)
    if default_autofire == nil then
        default_autofire = starting_default_autofire
    end
    cached_default_autofires[template_name] = default_autofire
end

mod.set_firemode_selection = function(asf)
    select_autofire = asf

    local firemode_element = mod.get_hud_element()
    if firemode_element then
        firemode_element:set_firemode(select_autofire)
    end
end

mod.is_in_autofire_mode = function()
    return select_autofire
end

mod._toggle_select = function(held)
    if not (track_autofire or track_natural) then
        ignore_next_autofire_default = true
    end
    mod.set_firemode_selection(not select_autofire)
end

mod:hook_safe(CLASS.PlayerUnitWeaponExtension, "on_slot_wielded", function(self, slot_name, ...)
    if self._player == Managers.player:local_player(1) then
        if remember_per_wep and wep_template_name and (track_autofire or track_natural) then
            mod.set_weapon_default(wep_template_name, select_autofire)
        end

        _disable_autofire()
        local wep_template = self._weapons[slot_name].weapon_template
        wep_template_name = wep_template.name
        autofire_delay_normal, autofire_delay_aim, natural_autofire_normal, natural_autofire_aim = mod.get_weapon_data(wep_template, include_psyker_bees)

        track_autofire = (autofire_delay_normal or autofire_delay_aim) and true or false
        autofire_delay_current = autofire_delay_normal

        track_natural = (natural_autofire_normal or natural_autofire_aim) and true or false
        natural_current = natural_autofire_normal

        if remember_per_wep and (track_autofire or track_natural) then
            if cached_default_autofires[wep_template_name] == nil then
                mod.set_weapon_default(wep_template_name, mod:get(wep_template_name))
            end
            if not ignore_next_autofire_default then
                mod.set_firemode_selection(cached_default_autofires[wep_template_name])
            end
            ignore_next_autofire_default = false
        end
    end
end)

mod:hook_safe(CLASS.GameModeManager, "init", function(self, game_mode_context, game_mode_name, ...)
    for template_name, autofire in pairs(cached_default_autofires) do
        mod:set(template_name, autofire)
    end
    table.clear(cached_default_autofires)
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
        shoot_charge_with_click = true
        _begin_aim()
    end
end)

mod:hook_safe(CLASS.WarpChargeActionModule, "finish", function(self, ...)
    if self._player_unit == _get_player_unit() then
        if is_firing then
            last_charge_level = 0.0
            chargeup_stage = CHARGEUP_SHOT_STAGE.delay
        end
        delayed_warp_end = true
    end
end)

local _fire_chargeup = function()
    if shoot_charge_with_click then
        chargeup_stage = CHARGEUP_SHOT_STAGE.repress
    else
        chargeup_stage = CHARGEUP_SHOT_STAGE.release
    end
end

mod:hook_safe(CLASS.PlayerUnitWeaponExtension, "fixed_update", function(self, unit, ...)
    if track_natural and chargeup_autofire and natural_current == NATURAL_MODE.chargeup and unit == _get_player_unit() then
        local action_module_charge_component = self._action_module_charge_component
        local charge_level = action_module_charge_component.charge_level
        if charge_level > 0.0 then
            if chargeup_stage == CHARGEUP_SHOT_STAGE.repress or last_charge_level > charge_level then
                chargeup_stage = CHARGEUP_SHOT_STAGE.holding
            end

            local charge_template = self:charge_template()
            local full_charge = chargeup_amt * (charge_template and charge_template.fully_charged_charge_level or 1)
            local max_charge = action_module_charge_component.max_charge
            max_charge = max_charge and math.min(max_charge, full_charge) or full_charge
            if chargeup_stage == CHARGEUP_SHOT_STAGE.holding and charge_level >= max_charge then
                _fire_chargeup()
            end
            last_charge_level = charge_level
        elseif (is_firing or shoot_for_me) and chargeup_stage == CHARGEUP_SHOT_STAGE.release then
            chargeup_stage = CHARGEUP_SHOT_STAGE.repress
        end
    end
end)

local _input_action_hook = function(func, self, action_name)
    local val = func(self, action_name)
    if track_autofire or (track_natural and (shoot_for_me or natural_current == NATURAL_MODE.chargeup)) then
        local is_lmb_action = action_name == "action_one_pressed"

        -- track if the user is holding down LMB
        if val and not shoot_for_me then
            if is_lmb_action then
                is_firing = true
                next_autofire = -1
            end
            if action_name == "action_one_release" then
                is_firing = false
            end
        end

        -- delay ending the warp charge attack properties, cuz they end between shots
        if delayed_warp_end and val and action_name == "action_two_release" then
            delayed_warp_end = false
            _end_aim()
        end

        if select_autofire then
            -- if this attack is a charge-up (helbore, staffs) or already fully-auto
            if track_natural and natural_current then
                if action_name == "action_one_hold" then
                    -- just shoot, unless the chargeup is finished
                    local is_holding = shoot_for_me or val
                    if is_holding and chargeup_stage == CHARGEUP_SHOT_STAGE.release then
                        return false
                    end
                    return is_holding
                end
                if natural_current == NATURAL_MODE.chargeup then
                    if is_lmb_action then
                        -- some attacks will require us to re-press LMB signal after firing a charge
                        if (is_firing or shoot_for_me) and chargeup_stage == CHARGEUP_SHOT_STAGE.repress then
                            return true
                        end
                        -- if the user clicks during an auto-shot chargeup, fire it prematurely
                        if val and shoot_for_me then
                            _fire_chargeup()
                        end
                    end
                end
            elseif is_lmb_action and (is_firing or shoot_for_me) and autofire_delay_current then
                -- the original core of the mod; signal LMB press every X seconds
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
