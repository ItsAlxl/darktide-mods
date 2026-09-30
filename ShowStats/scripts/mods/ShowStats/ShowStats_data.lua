local mod = get_mod("ShowStats")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id    = "auto_show",
				type          = "checkbox",
				default_value = true,
			},
			{
				setting_id    = "auto_expand",
				type          = "checkbox",
				default_value = true,
			},
			{
				setting_id    = "sort_subs",
				type          = "checkbox",
				default_value = true,
			},
		}
	}
}
