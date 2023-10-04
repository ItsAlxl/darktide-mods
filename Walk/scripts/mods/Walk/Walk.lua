local mod = get_mod("Walk")

local walk_speed = mod:get("walk_speed")
local sprint_cancels = mod:get("sprint_cancels")
local request_sprint = false
local ignore_next_unpress = false

mod.is_walking = false

mod.toggle_walk = function()
    mod.is_walking = not mod.is_walking
end

mod.held_walk = function(held)
    if not held and ignore_next_unpress then
        ignore_next_unpress = false
    else
        mod.is_walking = not mod.is_walking
    end
end

mod.on_setting_changed = function(id)
    local val = mod:get(id)
    if id == "walk_speed" then
        walk_speed = val
    elseif id == "sprint_cancels" then
        sprint_cancels = val
    end
end

local _is_move_action = function(act)
    return act == "move_right"
        or act == "move_left"
        or act == "move_forward"
        or act == "move_backward"
end

local _input_action_hook = function(func, self, action_name)
    local val = func(self, action_name)
    if mod.is_walking then
        if _is_move_action(action_name) then
            val = val * walk_speed
        elseif val and sprint_cancels and (action_name == "sprint" or action_name == "sprinting") then
            request_sprint = true
            ignore_next_unpress = true
            mod.is_walking = false
        end
    end
    return val
end
mod:hook(CLASS.InputService, "_get", _input_action_hook)
mod:hook(CLASS.InputService, "_get_simulate", _input_action_hook)

mod:hook_require("scripts/extension_systems/character_state_machine/character_states/utilities/sprint", function(instance)
    mod:hook(instance, "sprint_input", function(func, input_source, is_sprinting, sprint_requires_press_to_interrupt)
        if is_sprinting then
            request_sprint = false
        elseif request_sprint then
            return true
        end
        return func(input_source, is_sprinting, sprint_requires_press_to_interrupt)
    end)
end)
