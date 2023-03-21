local mod = get_mod("FullAuto")

local NORMAL_ACTIONS = { "action_shoot_hip", "action_shoot", "rapid_left", "action_shoot_flame" }
local AIMED_ACTIONS = { "action_shoot_zoomed" }

local FULLAUTO_FIREMODE = "full_auto"
local FIRE_DELAY = 0.1

local track_autofire = false
local autofire_normal = false
local autofire_aim = false

local autofire_current = false
local is_firing = false
local last_autofire = -1

local function _disable_autofire()
    track_autofire = false
    autofire_normal = false
    autofire_aim = false

    autofire_current = false
    is_firing = false
    last_autofire = -1
end

local function _check_action(template, primary)
    local actions = NORMAL_ACTIONS
    if not primary then
        actions = AIMED_ACTIONS
    end

    for _, a in pairs(actions) do
        if template.actions[a] then
            return true
        end
    end
    return false
end

local function _check_firemode(fm)
    if fm and fm ~= FULLAUTO_FIREMODE then
        return true
    end
    return false
end

local function _apply_weapon_template(template)
    _disable_autofire()
    if not template or not template.action_inputs then
        return
    end

    if _check_firemode(template.displayed_attacks.primary.fire_mode) then
        autofire_normal = _check_action(template, true)
    end
    if _check_firemode(template.displayed_attacks.secondary.fire_mode) then
        autofire_aim = _check_action(template, false)
    end

    track_autofire = autofire_normal or autofire_aim
    autofire_current = autofire_normal
end

mod:hook_safe("PlayerUnitWeaponExtension", "on_slot_wielded", function(self, slot_name, ...)
    if slot_name == "slot_secondary" then
        _apply_weapon_template(self._weapons[slot_name].weapon_template)
    else
        _disable_autofire()
    end
end)

mod:hook("InputService", "get", function(func, self, action_name)
    local val = func(self, action_name)
    if track_autofire then
        if val then
            if action_name == "action_one_pressed" then
                is_firing = true
                last_autofire = -1
            end
            if action_name == "action_one_release" then
                is_firing = false
            end

            if action_name == "action_two_pressed" then
                autofire_current = autofire_aim
            end
            if action_name == "action_two_release" then
                autofire_current = autofire_normal
            end
        end

        if is_firing and autofire_current and action_name == "action_one_pressed" then
            local this_t = Managers.time and Managers.time:time("main")
            if last_autofire < 0 or this_t - last_autofire >= FIRE_DELAY then
                last_autofire = this_t
                return true
            end
            return false
        end
    end

    return val
end)
