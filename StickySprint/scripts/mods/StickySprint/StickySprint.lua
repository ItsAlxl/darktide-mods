local mod = get_mod("StickySprint")

mod:hook_require("scripts/extension_systems/character_state_machine/character_states/utilities/sprint", function(instance)
    mod:hook(instance, "sprint_input", function(func, input_source, is_sprinting, sprint_requires_press_to_interrupt)
        local hold_to_sprint = input_source:get("hold_to_sprint")
        if not hold_to_sprint and is_sprinting then
            return true
        end
        return func(input_source, is_sprinting, sprint_requires_press_to_interrupt)
    end)
end)
