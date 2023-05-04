local mod = get_mod("Walk")

return {
	name = "Walk",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id      = "walk_key_toggle",
				type            = "keybind",
				default_value   = { },
				keybind_global  = false,
				keybind_trigger = "pressed",
				keybind_type    = "function_call",
				function_name   = "toggle_walk",
			},
			{
				setting_id      = "walk_key_held",
				type            = "keybind",
				default_value   = { },
				keybind_global  = false,
				keybind_trigger = "held",
				keybind_type    = "function_call",
				function_name   = "toggle_walk",
			},
			{
				setting_id      = "walk_speed",
				type            = "numeric",
				default_value   = 0.5,
				range           = {0.0, 1.0},
				decimals_number = 2,
			},
		}
	}
}
