local mod = get_mod("ToggleInteract")

local prev_interacting = false
local keep_interacting = false

mod:hook(CLASS.InputService, "get", function(func, self, action_name)
    local val = func(self, action_name)
    if val and action_name == "interact_pressed" then
        if keep_interacting then
            keep_interacting = false
        end
    end
    if keep_interacting and action_name == "interact_hold" then
        return true
    end
    return val
end)

mod:hook(CLASS.InteractorExtension, "is_interacting", function(func, self)
    local val = func(self)
    if val ~= prev_interacting then
        if val then
            keep_interacting = true
        else
            keep_interacting = false
        end
    end
    prev_interacting = val
    return val
end)

mod:hook(CLASS.LocalizationManager, "localize", function(func, self, key, ...)
    if key == "loc_interaction_input_type_hold" then
        key = "loc_interaction_input_type"
    end
    return func(self, key, ...)
end)
