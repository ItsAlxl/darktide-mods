local mod = get_mod("FullAuto")

local NORMAL_ACTIONS = { "action_shoot_hip", "action_shoot", "rapid_left", "action_shoot_flame" }
local NORMAL_CHAINS = { "shoot_pressed", "shoot", "shoot_charge" }
local AIMED_ACTIONS = { "action_shoot_zoomed" }
local AIMED_CHAINS = { "zoom_shoot" }
local FULLAUTO_FIREMODE = "full_auto"

local FALLBACK_DELAY = 0.25
local STANDARD_MULTIPLIER = 0.5
local SPRINT_MULTIPLIER = 1.1

local select_autofire = mod:get("default_autofire")
local track_autofire = false
local autofire_delay_normal = nil
local autofire_delay_aim = nil

local track_natural = false
local is_natural_autofire_normal = false
local is_natural_autofire_aim = false

local autofire_delay_current = nil
local natural_current = false
local is_firing = false
local shoot_for_me = mod:get("shoot_for_me")
local next_autofire = -1.0

local time_scale = 1.0
local is_sprinting = false

mod.on_setting_changed = function(id)
    if id == "shoot_for_me" then
        shoot_for_me = mod:get("shoot_for_me")
    end
end

local _disable_autofire = function()
    track_autofire = false
    autofire_delay_normal = nil
    autofire_delay_aim = nil

    track_natural = false
    is_natural_autofire_normal = false
    is_natural_autofire_aim = false

    autofire_delay_current = false
    natural_current = false
    is_firing = false
    next_autofire = -1
end

local _get_action = function(template, primary)
    local actions = NORMAL_ACTIONS
    if not primary then
        actions = AIMED_ACTIONS
    end

    for _, a in pairs(actions) do
        local act = template.actions[a]
        if act then
            return act
        end
    end
    return nil
end

local _get_chain_time = function(template, primary)
    local act = _get_action(template, primary)
    if act then
        local chain_actions = NORMAL_CHAINS
        if not primary then
            chain_actions = AIMED_CHAINS
        end

        for _, ca in pairs(chain_actions) do
            local chain = act.allowed_chain_actions[ca]
            if chain then
                return chain.chain_time
            end
        end
        return FALLBACK_DELAY
    end
    return nil
end

local _check_firemode = function(fm)
    return fm and fm.fire_mode and fm.fire_mode ~= FULLAUTO_FIREMODE
end

local _apply_weapon_template = function(template)
    _disable_autofire()
    if not template or not template.action_inputs then
        return
    end

    if _check_firemode(template.displayed_attacks.primary) then
        autofire_delay_normal = _get_chain_time(template, true)
    else
        is_natural_autofire_normal = true
    end
    if _check_firemode(template.displayed_attacks.secondary) or _check_firemode(template.displayed_attacks.extra) then
        autofire_delay_aim = _get_chain_time(template, false)
    else
        is_natural_autofire_aim = true
    end

    track_autofire = (autofire_delay_normal or autofire_delay_aim) and true or false
    autofire_delay_current = autofire_delay_normal

    track_natural = is_natural_autofire_normal or is_natural_autofire_aim
    natural_current = is_natural_autofire_normal
end

mod:hook_safe(CLASS.PlayerUnitWeaponExtension, "on_slot_wielded", function(self, slot_name, ...)
    if self._player == Managers.player:local_player(1) then
        if slot_name == "slot_secondary" then
            _apply_weapon_template(self._weapons[slot_name].weapon_template)
        else
            _disable_autofire()
        end
    end
end)

mod._toggle_select = function(held)
    select_autofire = not select_autofire
end

mod:hook_safe(CLASS.GameModeManager, "init", function(self, game_mode_context, game_mode_name, ...)
    if game_mode_name ~= "hub" then
        select_autofire = mod:get("default_autofire")
    end
end)

mod:hook_safe(CLASS.ActionHandler, "start_action", function(self, id, ...)
    local plr = Managers.player:local_player(1)
    if plr and plr.player_unit == self._unit then
        if id == "weapon_action" then
            time_scale = self._registered_components[id].component.time_scale
        end
    end
end)

mod:hook_require("scripts/extension_systems/character_state_machine/character_states/utilities/sprint", function(instance)
    mod:hook_safe(instance, "sprint_input", function(input_source, sprinting, ...)
        if is_sprinting ~= sprinting then
            is_sprinting = sprinting
        end
    end)
end)

local _input_action_hook = function(func, self, action_name, ...)
    local val = func(self, action_name, ...)
    if track_autofire or (track_natural and shoot_for_me) then
        local is_lmb_press = action_name == "action_one_pressed"
        if val then
            if not shoot_for_me then
                if is_lmb_press then
                    is_firing = true
                    next_autofire = -1
                end
                if action_name == "action_one_release" then
                    is_firing = false
                end
            end

            if action_name == "action_two_pressed" then
                autofire_delay_current = autofire_delay_aim
                natural_current = is_natural_autofire_aim
            end
            if action_name == "action_two_release" then
                autofire_delay_current = autofire_delay_normal
                natural_current = is_natural_autofire_normal
            end
        end

        if select_autofire then
            if track_natural then
                if natural_current and action_name == "action_one_hold" and select_autofire then
                    return true
                end
            elseif is_lmb_press and (is_firing or shoot_for_me) and autofire_delay_current then
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
