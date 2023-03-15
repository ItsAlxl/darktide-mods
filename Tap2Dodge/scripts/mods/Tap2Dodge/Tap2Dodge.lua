local mod = get_mod("Tap2Dodge")

local move_data = {
    move_left = {},
    move_right = {},
    move_backward = {}
}
local request_dodge = false

local max_delay = mod:get("max_delay")
local action_threshold = mod:get("action_threshold")

mod.on_setting_changed = function(id)
    if id == "max_delay" then
        max_delay = mod:get(id)
    elseif id == "action_threshold" then
        action_threshold = mod:get(id)
    end
end

mod:hook("InputService", "get", function(func, self, action_name)
    local val = func(self, action_name)

    if move_data[action_name] then
        local action = val >= action_threshold

        local fresh = not move_data[action_name].prev_act and action
        move_data[action_name].prev_act = action

        if fresh then
            local last_t = move_data[action_name].last_t
            local this_t = Managers.time and Managers.time:time("main")

            if last_t and last_t > 0 then
                request_dodge = (this_t - last_t) < max_delay
            end

            if request_dodge then
                move_data[action_name].last_t = nil
            else
                move_data[action_name].last_t = this_t
            end
        end
    end

    if action_name == "dodge" and request_dodge then
        val = true
        request_dodge = false
    end

    return val
end)
