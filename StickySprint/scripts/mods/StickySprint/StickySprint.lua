local mod = get_mod("StickySprint")

local ignore_sprint_action = false
local request_sprint = false

mod:hook_require("scripts/extension_systems/character_state_machine/character_states/utilities/sprint", function(instance)
	mod:hook(instance, "sprint_input", function(func, input_source, is_sprinting, sprint_requires_press_to_interrupt)
		if request_sprint then
			if is_sprinting then
				request_sprint = false
			else
				return true
			end
		end

		if ignore_sprint_action and not is_sprinting then
			ignore_sprint_action = false
		end
		return func(input_source, is_sprinting, sprint_requires_press_to_interrupt)
	end)
end)

mod:hook_safe(CLASS.GameModeManager, "init", function(...)
	ignore_sprint_action = false
	request_sprint = false
end)

local _input_action_hook = function(func, self, action_name)
	local val = func(self, action_name)
	if action_name == "sprint" then
		if ignore_sprint_action then
			return false
		elseif val then
			ignore_sprint_action = true
			request_sprint = true
		end
	end
	return val
end
mod:hook(CLASS.InputService, "_get", _input_action_hook)
mod:hook(CLASS.InputService, "_get_simulate", _input_action_hook)
