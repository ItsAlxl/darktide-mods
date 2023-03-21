local mod = get_mod("KeepSwinging")

local SWING_DELAY_FRAMES = 10
local RELEASE_DELAY_FRAMES = 1

local attack_action_requests = {
    action_one_pressed = false,
    action_one_hold = false,
    action_one_release = false,
}
local disable_actions = {
    action_one_pressed = mod:get("disable_after_action_one"),
    action_two_pressed = mod:get("disable_after_action_two"),
    weapon_reload = mod:get("disable_after_weapon_reload"),
    weapon_extra_pressed = mod:get("disable_after_weapon_extra"),
}

local allow_autoswing = false
local is_swinging = false
local as_modifier = mod:get("as_modifier")
local wield_default = mod:get("wield_default")

local swing_delay = 1
local release_delay = 1
local request_repress = false

mod.on_setting_changed = function(id)
    if id == "as_modifier" then
        as_modifier = mod:get(id)
    elseif id == "wield_default" then
        wield_default = mod:get(id)
    elseif id == "disable_after_action_one" then
        disable_actions.action_one_pressed = mod:get(id)
    elseif id == "disable_after_action_two" then
        disable_actions.action_two_pressed = mod:get(id)
    elseif id == "disable_after_weapon_extra" then
        disable_actions.weapon_extra_pressed = mod:get(id)
    elseif id == "disable_after_weapon_reload" then
        disable_actions.weapon_reload = mod:get(id)
    end
end

local function _allow_autoswing(a)
    allow_autoswing = a
    is_swinging = a and wield_default
end

local function _start_attack_request(include_press)
    if include_press then
        attack_action_requests.action_one_pressed = true
    end
    attack_action_requests.action_one_hold = true
end

local function _finish_attack_request()
    attack_action_requests.action_one_release = true
end

mod:hook_safe("PlayerUnitWeaponExtension", "on_slot_wielded", function(self, slot_name, ...)
    _allow_autoswing(slot_name == "slot_primary")
end)

mod._toggle_swinging = function(held)
    is_swinging = not is_swinging
    if is_swinging then
        swing_delay = 1
    else
        request_repress = as_modifier
    end
end

local function _consume_action_request(act)
    if attack_action_requests[act] then
        attack_action_requests[act] = false
        return true
    end
    return false
end

mod:hook("InputService", "get", function(func, self, action_name)
    local val = func(self, action_name)

    if allow_autoswing and is_swinging then
        if val and disable_actions[action_name] and (not as_modifier or action_name ~= "action_one_pressed") then
            mod._toggle_swinging()
        end

        if action_name == "action_one_hold" then
            if as_modifier == val then
                local request = _consume_action_request(action_name)

                if swing_delay > 0 then
                    swing_delay = swing_delay - 1

                    if swing_delay == 0 then
                        _start_attack_request(as_modifier or not val)
                        swing_delay = SWING_DELAY_FRAMES
                    end
                end

                if release_delay > 0 then
                    release_delay = release_delay - 1
                    if release_delay == 0 then
                        _finish_attack_request()
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

    if request_repress and action_name == "action_one_pressed" then
        request_repress = false
        return true
    end

    return val
end)
