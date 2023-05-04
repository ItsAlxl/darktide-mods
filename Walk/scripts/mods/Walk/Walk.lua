local mod = get_mod("Walk")

local walk_speed = mod:get("walk_speed")

mod.is_walking = false
mod.toggle_walk = function(held)
    mod.is_walking = not mod.is_walking
end

mod.on_setting_changed = function(id)
    local val = mod:get(id)
    if id == "walk_speed" then
        walk_speed = val
    end
end

local _is_move_action = function(act)
    return act == "move_right"
    or act == "move_left"
    or act == "move_forward"
    or act == "move_backward"
end

mod:hook(CLASS.InputService, "get", function(func, self, action_name)
    local val = func(self, action_name)
    if mod.is_walking and _is_move_action(action_name) then
        val = val * walk_speed
    end
    return val
end)
