local mod = get_mod("PanicStimm")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id      = "key_autostimm",
				type            = "keybind",
				default_value   = {},
				keybind_global  = false,
				keybind_trigger = "pressed",
				keybind_type    = "function_call",
				function_name   = "_quick_inject",
			},
			{
				setting_id    = "after_inject",
				type          = "dropdown",
				default_value = "PREVIOUS",
				options       = {
					{ text = "after_normal",    value = "" },
					{ text = "after_previous",  value = "PREVIOUS" },
					{ text = "after_primary",   value = "wield_1" },
					{ text = "after_secondary", value = "wield_2" },
					{ text = "after_blitz",     value = "grenade_ability_pressed" },
				},
			},
		}
	}
}
