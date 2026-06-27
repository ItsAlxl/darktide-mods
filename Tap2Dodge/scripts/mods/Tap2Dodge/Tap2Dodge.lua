local mod = get_mod("Tap2Dodge")

local move_data = {
    move_left = {},
    move_right = {},
    move_backward = {}
}

local DODGE_PRESS_BUFFER = 0.05
local last_dodge_request = 0

local max_delay = mod:get("max_delay")
local action_threshold = mod:get("action_threshold")
local dodge_while_running = mod:get("dodge_while_running")

mod.on_setting_changed = function(id)
    if id == "max_delay" then
        max_delay = mod:get(id)
    elseif id == "action_threshold" then
        action_threshold = mod:get(id)
    elseif id == "dodge_while_running" then
        dodge_while_running = mod:get(id)
    end
end

local function time_now()
    return (Managers.time and Managers.time:time("main")) or 0
end

local function dodge_buffered()
    return last_dodge_request > 0 and (time_now() - last_dodge_request) < DODGE_PRESS_BUFFER
end

local _input_action_hook = function(func, self, action_name)
    local val = func(self, action_name)

    if move_data[action_name] then
        local action = val >= action_threshold

        local fresh = not move_data[action_name].prev_act and action
        move_data[action_name].prev_act = action

        if fresh then
            local last_t = move_data[action_name].last_t
            local this_t = time_now()
            local request_dodge = false

            if last_t and last_t > 0 then
                request_dodge = (this_t - last_t) < max_delay
            end

            if request_dodge then
                move_data[action_name].last_t = nil
                last_dodge_request = this_t
            else
                move_data[action_name].last_t = this_t
            end
        end
    end

    if action_name == "dodge" then
        if dodge_buffered() then
            return true
        end
        return val
    end

    if dodge_while_running and action_name == "sprinting" and dodge_buffered() then
        return false
    end

    return val
end
mod:hook(CLASS.InputService, "_get", _input_action_hook)
mod:hook(CLASS.InputService, "_get_simulate", _input_action_hook)
