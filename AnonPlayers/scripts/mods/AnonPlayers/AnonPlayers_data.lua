local mod = get_mod("AnonPlayers")

local anon_mode_dropdown = {
	{ text = "am_none", value = 0 },
	{ text = "am_botname", value = 4 },
	{ text = "am_personality", value = 2 },
	{ text = "am_mask", value = 1 },
	{ text = "am_hash", value = 3 },
}

return {
	name = "AnonPlayers",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id    = "anon_others",
				type          = "dropdown",
				default_value = 4,
				options       = anon_mode_dropdown,
			},
			{
				setting_id    = "anon_other_accounts",
				type          = "dropdown",
				default_value = 1,
				options       = table.clone(anon_mode_dropdown),
			},
			{
				setting_id    = "show_other_platform",
				type          = "checkbox",
				default_value = false,
			},
			{
				setting_id    = "anon_me",
				type          = "dropdown",
				default_value = 0,
				options       = table.clone(anon_mode_dropdown),
			},
			{
				setting_id    = "anon_my_account",
				type          = "dropdown",
				default_value = 1,
				options       = table.clone(anon_mode_dropdown),
			},
			{
				setting_id    = "show_my_platform",
				type          = "checkbox",
				default_value = false,
			},
		}
	}
}
