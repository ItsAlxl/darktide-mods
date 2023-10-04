local mod = get_mod("KeepSwinging")

local SWING_DELAY_FRAMES = 10
local RELEASE_DELAY_FRAMES = 1

local attack_action_requests = {
    action_one_pressed = false,
    action_one_hold = false,
    action_one_release = false,
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

local allow_autoswing = false
local is_swinging = false

local held_interrupted = false
local holding_action_one = false

local as_modifier = mod:get("as_modifier")
local wield_default = mod:get("wield_default")
local persist_after_disable = mod:get("persist_after_disable")

local swing_delay = 1
local release_delay = 1
local request_repress = false

local function _is_interrupted()
    for _, t in pairs(disable_actions) do
        if t.active and t.enabled then
            return true
        end
    end
    return false
end

mod.on_setting_changed = function(id)
    if id == "as_modifier" then
        as_modifier = mod:get(id)
    elseif id == "wield_default" then
        wield_default = mod:get(id)
    elseif id == "persist_after_disable" then
        persist_after_disable = mod:get(id)
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

local function _allow_autoswing(a)
    allow_autoswing = a
    is_swinging = a and wield_default
end

local function _start_attack_request()
    if as_modifier or not holding_action_one then
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
    if held == false and held_interrupted then
        held_interrupted = false
        return
    end

    is_swinging = not is_swinging
    if allow_autoswing then
        if is_swinging then
            swing_delay = 1
        else
            request_repress = as_modifier and holding_action_one
            for act, _ in pairs(disable_actions) do
                disable_actions[act].active = false
            end
        end
    end
end

local function _consume_action_request(act)
    if attack_action_requests[act] then
        attack_action_requests[act] = false
        return true
    end
    return false
end

local _input_action_hook = function(func, self, action_name)
    local val = func(self, action_name)

    if allow_autoswing and is_swinging then
        if disable_actions[action_name] and disable_actions[action_name].enabled and (not as_modifier or action_name ~= "action_one_hold") then
            disable_actions[action_name].active = val
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
            if action_name == "action_one_hold" then
                holding_action_one = val
                if as_modifier == val then
                    local request = _consume_action_request(action_name)

                    if swing_delay > 0 then
                        swing_delay = swing_delay - 1

                        if swing_delay == 0 then
                            _start_attack_request()
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
    end

    if request_repress and action_name == "action_one_pressed" then
        request_repress = false
        return true
    end

    return val
end
mod:hook(CLASS.InputService, "_get", _input_action_hook)
mod:hook(CLASS.InputService, "_get_simulate", _input_action_hook)
