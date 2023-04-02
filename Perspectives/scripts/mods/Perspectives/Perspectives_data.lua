local mod = get_mod("Perspectives")

return {
	name = "Perspectives",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id      = "toggle_perspective_keybind",
				type            = "keybind",
				default_value   = {},
				keybind_global  = false,
				keybind_trigger = "pressed",
				keybind_type    = "function_call",
				function_name   = "toggle_third_person",
			},
			{
				setting_id      = "cycle_shoulder",
				type            = "keybind",
				default_value   = {},
				keybind_global  = false,
				keybind_trigger = "pressed",
				keybind_type    = "function_call",
				function_name   = "cycle_shoulder",
			},
			{
				setting_id    = "aim_mode",
				type          = "dropdown",
				default_value = 0,
				options       = {
					{ text = "aim_cycle", value = 0 },
					{ text = "aim_center", value = 1 },
					{ text = "aim_1p", value = 2 },
				},
			},
			{
				setting_id    = "cycle_includes_center",
				type          = "checkbox",
				default_value = false,
			},
			{
				setting_id      = "perspective_transition_time",
				type            = "numeric",
				default_value   = 0.1,
				range           = { 0.0, 1.0 },
				decimals_number = 1,
			},
			{
				setting_id    = "default_perspective_mode",
				type          = "dropdown",
				default_value = 2,
				options       = {
					{ text = "defper_normal",       value = 0 },
					{ text = "defper_swapped",      value = -1 },
					{ text = "defper_always_first", value = 1 },
					{ text = "defper_always_third", value = 2 },
				},
			},
		}
	}
}
