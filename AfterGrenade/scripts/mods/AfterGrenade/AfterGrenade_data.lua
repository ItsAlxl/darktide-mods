local mod = get_mod("AfterGrenade")

local dropdown_options = {
	{ text = "after_normal",    value = "" },
	{ text = "after_keep",      value = "grenade_ability_pressed" },
	{ text = "after_previous",  value = "PREVIOUS" },
	{ text = "after_primary",   value = "wield_1" },
	{ text = "after_secondary", value = "wield_2" },
}

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id    = "ag_zealot",
				type          = "dropdown",
				default_value = "wield_1",
				options       = table.clone(dropdown_options),
			},
			{
				setting_id    = "ag_veteran",
				type          = "dropdown",
				default_value = "grenade_ability_pressed",
				options       = table.clone(dropdown_options),
			},
			{
				setting_id    = "ag_ogryn",
				type          = "dropdown",
				default_value = "",
				options       = table.clone(dropdown_options),
			},
			{
				setting_id    = "ag_psyker",
				type          = "dropdown",
				default_value = "",
				options       = dropdown_options,
			},
		}
	}
}
