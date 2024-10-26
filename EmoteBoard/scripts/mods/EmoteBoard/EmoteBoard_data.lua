local mod = get_mod("EmoteBoard")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "pressed_show",
				type = "keybind",
				default_value = {},
				keybind_global = false,
				keybind_trigger = "pressed",
				keybind_type = "function_call",
				function_name = "_kb_toggle_show",
			},
			{
				setting_id = "held_show",
				type = "keybind",
				default_value = {},
				keybind_global = false,
				keybind_trigger = "held",
				keybind_type = "function_call",
				function_name = "_kb_toggle_show",
			},
		}
	}
}
