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
				keybind_trigger = "held",
				keybind_type    = "function_call",
				function_name   = "_kb_hold_to_inject",
			},
			{
				setting_id    = "autostimm_hold_behavior",
				type          = "dropdown",
				default_value = -1,
				options       = {
					{ text = "press_to_inject",    value = 0 },
					{ text = "hold_to_inject",     value = 1 },
					{ text = "hold_to_not_inject", value = -1 },
				},
			},
			{
				setting_id      = "autostimm_held_delay",
				type            = "numeric",
				default_value   = 0.3,
				range           = { 0.0, 2.5 },
				decimals_number = 1
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
