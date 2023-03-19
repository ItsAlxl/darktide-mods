local mod = get_mod("KeepSwinging")

return {
	name = "KeepSwinging",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id      = "held_keybind",
				type            = "keybind",
				default_value   = {},
				keybind_global  = false,
				keybind_trigger = "held",
				keybind_type    = "function_call",
				function_name   = "_toggle_swinging",
			},
			{
				setting_id      = "pressed_keybind",
				type            = "keybind",
				default_value   = {},
				keybind_global  = false,
				keybind_trigger = "pressed",
				keybind_type    = "function_call",
				function_name   = "_toggle_swinging",
			},
		}
	}
}
