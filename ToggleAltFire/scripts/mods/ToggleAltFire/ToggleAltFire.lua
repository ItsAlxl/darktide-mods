local mod = get_mod("ToggleAltFire")

local UNTOGGLE_STATES = {
    ledge_hanging = true,
    warp_grabbed = true,
    dead = true,
    hogtied = true,
    grabbed = true,
    catapulted = true,
    knocked_down = true,
    consumed = true,
    netted = true,
    mutant_charged = true,
    pounced = true,
    stunned = true,
    interacting = true,
}

local untoggle_actions = {
    action_shoot_braced = false,
    action_shoot_charged = false,
    action_vent = true,
    action_reload = false,
}

local toggleable_weapon_categories = {
    autogun = true,
    autopistol = true,
    lasgun = true,
    laspistol = true,
    stub_rifle = true,
    stub_pistol = true,
    shotgun = true,
    rippergun = true,
    bolter = true,
    heavystubber = true,
    grenadier_gauntlet = true,
    shotgun_grenade = true,
    plasma_rifle = true,
    flamer = true,
    force_staff = true
}

mod.on_setting_changed = function(id)
    if toggleable_weapon_categories[id] ~= nil then
        toggleable_weapon_categories[id] = mod:get(id)
    end
    if untoggle_actions[id] ~= nil then
        untoggle_actions[id] = mod:get(id)
    end
end

for cat, _ in pairs(toggleable_weapon_categories) do
    mod.on_setting_changed(cat)
end

local perform_toggle = false
local toggle_state = false
local prev_act = false

local function _set_toggleable(t)
    perform_toggle = t
    toggle_state = false
    prev_act = false
end

mod:hook("InputService", "get", function(func, self, action_name)
    local val = func(self, action_name)
    if perform_toggle and action_name == "action_two_hold" then
        local fresh = not prev_act and val
        prev_act = val
        if fresh then
            toggle_state = not toggle_state
        end
        return toggle_state
    end
    return val
end)

mod:hook_safe("CharacterStateMachine", "_change_state", function(self, unit, dt, t, next_state, ...)
    if perform_toggle then
        --[[
        if next_state ~= "walking" and next_state ~= "sprinting" and UNTOGGLE_STATES[next_state] == nil then
            mod:echo("State: %s", next_state)
        end
        --]]
        if UNTOGGLE_STATES[next_state] then
            toggle_state = false
        end
    end
end)

mod:hook_safe("ActionHandler", "start_action", function(self, id, action_objects, action_name, ...)
    if perform_toggle then
        --[[
        if action_name ~= "action_wield" and action_name ~= "action_unwield" and untoggle_actions[action_name] == nil then
            mod:echo("Action: %s", action_name)
        end
        --]]
        if untoggle_actions[action_name] then
            toggle_state = false
        end
    end
end)

local function _is_toggleable_weapon(template)
    for _, k in pairs(template.keywords) do
        if toggleable_weapon_categories[k] then
            return true
        end
    end
    return false
end

mod:hook_safe("PlayerUnitWeaponExtension", "on_slot_wielded", function(self, slot_name, ...)
    _set_toggleable(slot_name == "slot_secondary" and _is_toggleable_weapon(self._weapons[slot_name].weapon_template))
end)
