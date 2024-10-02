local mod = get_mod("KeepSwinging")

local SWING_DELAY_FRAMES = 10
local RELEASE_DELAY_FRAMES = 2
local VALID_MELEE_SPECIAL_TYPES = { "special_attack", "melee_hand" }
local VALID_RANGED_SPECIAL_TYPES = { "melee", "melee_hand" }
local ACTION_SETS = {
    action_one_hold = {
        press = "action_one_pressed",
        hold = "action_one_hold",
        release = "action_one_release",
    },
    weapon_extra_hold = {
        press = "weapon_extra_pressed",
        hold = "weapon_extra_hold",
        release = "weapon_extra_release",
    },
}

local disable_actions = {
    action_one_hold = {},
    action_two_hold = {},
    weapon_reload_hold = {},
    weapon_extra_hold = {},
}
for act, _ in pairs(disable_actions) do
    disable_actions[act] = {
        enabled = mod:get("disable_" .. act),
        active = false,
    }
end

local allow_swinging = false
local allow_primary = false
local allow_special = false
local is_swinging = mod:get("default_mode")

local held_interrupted = false
local current_action = "action_one_hold"
local holding_current_action = false
local attack_action_requests = {}

local as_modifier = mod:get("as_modifier")
local persist_after_disable = mod:get("persist_after_disable")

local swing_delay = 1
local release_delay = 1
local request_repress = false

local include_melee_primary = mod:get("include_melee_primary")
local include_melee_specials = mod:get("include_melee_specials")
local include_gauntlets = mod:get("include_gauntlets")
local include_ranged_specials = mod:get("include_ranged_specials")

local _is_interrupted = function()
    for action, t in pairs(disable_actions) do
        if (not as_modifier or action ~= current_action) and t.active and t.enabled then
            return true
        end
    end
    return false
end

local mode_hud_element = {
    package = "packages/ui/views/inventory_background_view/inventory_background_view",
    use_hud_scale = true,
    class_name = "HudElementKeepSwingingMode",
    filename = "KeepSwinging/scripts/mods/KeepSwinging/HudElementKeepSwingingMode",
    visibility_groups = {
        "alive",
        "communication_wheel",
        "tactical_overlay"
    }
}
mod:add_require_path(mode_hud_element.filename)

local _add_hud_element = function(element_pool)
    local found_key, _ = table.find_by_key(element_pool, "class_name", mode_hud_element.class_name)
    if found_key then
        element_pool[found_key] = mode_hud_element
    else
        table.insert(element_pool, mode_hud_element)
    end
end
mod:hook_require("scripts/ui/hud/hud_elements_player_onboarding", _add_hud_element)
mod:hook_require("scripts/ui/hud/hud_elements_player", _add_hud_element)

local _get_hud_element = function()
    local hud = Managers.ui:get_hud()
    return hud and hud:element("HudElementKeepSwingingMode")
end

mod.on_setting_changed = function(id)
    if id == "hud_element" then
        local mode_element = _get_hud_element()
        if mode_element then
            mode_element:set_enabled(mod:get(id))
        end
    elseif id == "hud_element_size" then
        local mode_element = _get_hud_element()
        if mode_element then
            mode_element:set_side_length(mod:get(id))
        end
    elseif id == "as_modifier" then
        as_modifier = mod:get(id)
    elseif id == "persist_after_disable" then
        persist_after_disable = mod:get(id)
    elseif id == "include_melee_primary" then
        include_melee_primary = mod:get(id)
    elseif id == "include_melee_specials" then
        include_melee_specials = mod:get(id)
    elseif id == "include_gauntlets" then
        include_gauntlets = mod:get(id)
    elseif id == "include_ranged_specials" then
        include_ranged_specials = mod:get(id)
    elseif id == "disable_action_one_hold" then
        disable_actions.action_one_hold.enabled = mod:get(id)
    elseif id == "disable_action_two_hold" then
        disable_actions.action_two_hold.enabled = mod:get(id)
    elseif id == "disable_weapon_reload_hold" then
        disable_actions.weapon_reload_hold.enabled = mod:get(id)
    elseif id == "disable_weapon_extra_hold" then
        disable_actions.weapon_extra_hold.enabled = mod:get(id)
    end
end

local _start_attack_request = function(current_action_set)
    if as_modifier or not holding_current_action then
        attack_action_requests[current_action_set.press] = true
    end
    attack_action_requests[current_action_set.hold] = true
end

local _finish_attack_request = function(current_action_set)
    attack_action_requests[current_action_set.release] = true
end

local _set_autoswing = function(auto_swinging)
    is_swinging = auto_swinging
    if auto_swinging then
        swing_delay = 1
    else
        request_repress = as_modifier and holding_current_action
        for act, _ in pairs(disable_actions) do
            disable_actions[act].active = false
        end
    end

    local mode_element = _get_hud_element()
    if mode_element then
        mode_element:set_mode(is_swinging)
    end
end

mod.is_in_auto_mode = function()
    return is_swinging
end

local _is_valid_melee_special = function(special_attack)
    return table.contains(VALID_MELEE_SPECIAL_TYPES, special_attack.type)
end

local _is_valid_ranged_special = function(special_attack)
    return table.contains(VALID_RANGED_SPECIAL_TYPES, special_attack.type)
end

mod:hook_safe(CLASS.PlayerUnitWeaponExtension, "on_slot_wielded", function(self, slot_name, ...)
    if self._player == Managers.player:local_player(1) then
        local wep = self._weapons[slot_name].weapon_template
        local keywords = wep and wep.keywords
        if keywords then
            local is_melee = keywords and table.contains(keywords, "melee")
            local special_attack = wep.displayed_attacks and wep.displayed_attacks.special

            if is_melee then
                allow_primary = include_melee_primary
                allow_special = special_attack and include_melee_specials and _is_valid_melee_special(special_attack)
            else
                allow_primary = include_gauntlets and table.contains(keywords, "grenadier_gauntlet")
                allow_special = special_attack and include_ranged_specials and _is_valid_ranged_special(special_attack)
            end
        else
            allow_primary = false
            allow_special = false
        end
        current_action = allow_primary and "action_one_hold" or "weapon_extra_hold"
        allow_swinging = allow_primary or allow_special
    end
end)

mod._toggle_swinging = function(held)
    if held == false and held_interrupted then
        held_interrupted = false
        return
    end

    _set_autoswing(not is_swinging)
end

local _consume_action_request = function(act)
    if attack_action_requests[act] then
        attack_action_requests[act] = false
        return true
    end
    return false
end

local _input_action_hook = function(func, self, action_name)
    local val = func(self, action_name)
    local current_action_set = ACTION_SETS[current_action]
    if allow_swinging and is_swinging then
        if disable_actions[action_name] and disable_actions[action_name].enabled and (not as_modifier or action_name ~= "action_one_hold") then
            disable_actions[action_name].active = val
        end

        if val and (allow_primary and action_name == "action_one_hold" or allow_special and action_name == "weapon_extra_hold") then
            current_action = action_name
            current_action_set = ACTION_SETS[current_action]
        end

        local skip = false
        if _is_interrupted() then
            if persist_after_disable then
                skip = true
            else
                held_interrupted = true
                mod._toggle_swinging()
            end
        end

        if not skip then
            if action_name == current_action then
                holding_current_action = val
                if as_modifier == val then
                    local request = _consume_action_request(action_name)

                    if swing_delay > 0 then
                        swing_delay = swing_delay - 1

                        if swing_delay == 0 then
                            _start_attack_request(current_action_set)
                            swing_delay = SWING_DELAY_FRAMES
                        end
                    end

                    if release_delay > 0 then
                        release_delay = release_delay - 1
                        if release_delay == 0 then
                            _finish_attack_request(current_action_set)
                        end
                    end

                    if request then
                        release_delay = RELEASE_DELAY_FRAMES
                        return true
                    end
                    return release_delay > 0
                else
                    return val
                end
            end

            if attack_action_requests[action_name] then
                return _consume_action_request(action_name)
            end
        end
    end

    if request_repress and action_name == current_action_set.press then
        request_repress = false
        return true
    end

    return val
end
mod:hook(CLASS.InputService, "_get", _input_action_hook)
mod:hook(CLASS.InputService, "_get_simulate", _input_action_hook)

mod:hook_safe(CLASS.GameModeManager, "init", function(self, game_mode_context, game_mode_name, ...)
    if game_mode_name ~= "hub" then
        _set_autoswing(mod:get("default_mode"))
    end
end)
