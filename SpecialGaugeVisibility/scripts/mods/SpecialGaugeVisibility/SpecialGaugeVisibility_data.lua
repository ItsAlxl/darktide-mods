local mod = get_mod("SpecialGaugeVisibility")

local vis_options = {
	{ text = "show_default",   value = -1 },
	{ text = "show_equipped", value = 0 },
	{ text = "show_always",  value = 1 },
}

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "kill_charges",
				type = "dropdown",
				default_value = 1,
				options = vis_options,
			},
			{
				setting_id = "overheat_lockout",
				type = "dropdown",
				default_value = 1,
				options = table.clone(vis_options),
			},
		}
	}
}
