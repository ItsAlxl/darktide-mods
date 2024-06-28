local mod = get_mod("BetterMelk")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "corner",
				type = "dropdown",
				default_value = "tr",
				options = {
					{ text = "corner_tl", value = "tl" },
					{ text = "corner_tr", value = "tr" },
					{ text = "corner_bl", value = "bl" },
					{ text = "corner_br", value = "br" },
				},
			},
			{
				setting_id    = "offset_x",
				type          = "numeric",
				default_value = 0,
				range         = { -20, 500 },
			},
			{
				setting_id    = "offset_y",
				type          = "numeric",
				default_value = 0,
				range         = { -10, 80 },
			},
		}
	}
}
