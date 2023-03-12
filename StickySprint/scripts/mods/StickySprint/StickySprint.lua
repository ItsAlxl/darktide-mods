local mod = get_mod("StickySprint")

local keep_sprinting = false

mod:hook_require("scripts/extension_systems/character_state_machine/character_states/utilities/sprint", function(instance)
    mod:hook_safe(instance, "sprint_input", function(input_source, is_sprinting, sprint_requires_press_to_interrupt)
        if keep_sprinting and not is_sprinting then
            keep_sprinting = false
        end
    end)
end)

mod:hook("InputService", "get", function(func, self, action_name)
    local val = func(self, action_name)
    if action_name == "sprint" then
        if keep_sprinting then
            val = false
        else
            keep_sprinting = true
        end
    end
    return val
end)
