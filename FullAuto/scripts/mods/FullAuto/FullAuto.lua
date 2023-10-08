local mod = get_mod("FullAuto")

local NORMAL_ACTIONS = { "action_shoot_hip", "action_shoot", "rapid_left", "action_shoot_flame", "action_rapid_left", "action_rapid_right" }
local NORMAL_CHAINS = { "shoot_pressed", "shoot", "shoot_charge" }
local AIMED_ACTIONS = { "action_shoot_zoomed", "action_rapid_zoomed" }
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

local include_psyker_bees = mod:get("include_psyker_bees")

local time_scale = 1.0
local is_sprinting = false

local firemode_hud_element = {
    package = "packages/ui/views/inventory_background_view/inventory_background_view",
    use_retained_mode = true,
    use_hud_scale = true,
    class_name = "HudElementFullAutoFireMode",
    filename = "FullAuto/scripts/mods/FullAuto/HudElementFullAutoFireMode",
    visibility_groups = {
        "alive",
        "communication_wheel",
        "tactical_overlay"
    }
}
mod:add_require_path(firemode_hud_element.filename)

local _add_hud_element = function(element_pool)
    local found_key, _ = table.find_by_key(element_pool, "class_name", firemode_hud_element.class_name)
    if found_key then
        element_pool[found_key] = firemode_hud_element
    else
        table.insert(element_pool, firemode_hud_element)
    end
end
mod:hook_require("scripts/ui/hud/hud_elements_player_onboarding", _add_hud_element)
mod:hook_require("scripts/ui/hud/hud_elements_player", _add_hud_element)

local _get_hud_element = function()
    local hud = Managers.ui:get_hud()
    return hud and hud:element("HudElementFullAutoFireMode")
end

mod.on_setting_changed = function(id)
    if id == "hud_element" then
        local firemode_element = _get_hud_element()
        if firemode_element then
            firemode_element:update_vis(mod:get(id))
        end
    elseif id == "include_psyker_bees" then
        include_psyker_bees = mod:get(id)
    elseif id == "shoot_for_me" then
        shoot_for_me = mod:get(id)
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
    if not template or not template.action_inputs or not template.displayed_attacks then
        return
    end

    local is_bees = template.psyker_smite
    if is_bees or _check_firemode(template.displayed_attacks.primary) then
        autofire_delay_normal = _get_chain_time(template, true)
    elseif template.fire_mode then
        is_natural_autofire_normal = true
    end
    if is_bees or _check_firemode(template.displayed_attacks.secondary) or _check_firemode(template.displayed_attacks.extra) then
        autofire_delay_aim = _get_chain_time(template, false)
    elseif template.fire_mode then
        is_natural_autofire_aim = true
    end

    track_autofire = (autofire_delay_normal or autofire_delay_aim) and true or false
    autofire_delay_current = autofire_delay_normal

    track_natural = is_natural_autofire_normal or is_natural_autofire_aim
    natural_current = is_natural_autofire_normal
end

mod:hook_safe(CLASS.PlayerUnitWeaponExtension, "on_slot_wielded", function(self, slot_name, ...)
    if self._player == Managers.player:local_player(1) then
        local wep = self._weapons[slot_name].weapon_template
        if not (slot_name == "slot_secondary" or (include_psyker_bees and wep.name == "psyker_throwing_knives")) then
            wep = nil
        end
        _apply_weapon_template(wep)
    end
end)

local _set_firemode_selection = function(asf)
    select_autofire = asf

    local firemode_element = _get_hud_element()
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

mod:hook_require("scripts/utilities/alternate_fire", function(AlternateFire)
    mod:hook_safe(AlternateFire, "start", function(alternate_fire_component, weapon_tweak_templates_component, spread_control_component, sway_control_component, sway_component, movement_state_component, peeking_component, first_person_extension, animation_extension, weapon_extension, weapon_template, player_unit, ...)
        if player_unit == _get_player_unit() then
            autofire_delay_current = autofire_delay_aim
            natural_current = is_natural_autofire_aim
        end
    end)

    mod:hook_safe(AlternateFire, "stop", function(alternate_fire_component, peeking_component, first_person_extension, weapon_tweak_templates_component, animation_extension, weapon_template, skip_stop_anim, player_unit, ...)
        if player_unit == _get_player_unit() then
            autofire_delay_current = autofire_delay_normal
            natural_current = is_natural_autofire_normal
        end
    end)
end)

local _input_action_hook = function(func, self, action_name)
    local val = func(self, action_name)
    if track_autofire or (track_natural and shoot_for_me) then
        local is_lmb_press = action_name == "action_one_pressed"
        if val and not shoot_for_me then
            if is_lmb_press then
                is_firing = true
                next_autofire = -1
            end
            if action_name == "action_one_release" then
                is_firing = false
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
