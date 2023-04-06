local mod = get_mod("ReorderChars")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id      = "move_up",
				type            = "keybind",
				default_value   = { "w" },
				keybind_trigger = "pressed",
				keybind_type    = "function_call",
				function_name   = "move_current_up",
			},
			{
				setting_id      = "move_down",
				type            = "keybind",
				default_value   = { "s" },
				keybind_trigger = "pressed",
				keybind_type    = "function_call",
				function_name   = "move_current_down",
			},
		}
	}
}
