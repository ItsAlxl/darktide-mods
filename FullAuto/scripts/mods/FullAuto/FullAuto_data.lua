local mod = get_mod("FullAuto")

return {
	name = "FullAuto",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id      = "toggle_keybind",
				type            = "keybind",
				default_value   = {},
				keybind_global  = false,
				keybind_trigger = "pressed",
				keybind_type    = "function_call",
				function_name   = "_toggle_select",
			},
			{
				setting_id    = "default_autofire",
				type          = "checkbox",
				default_value = true,
			},
		}
	}
}
