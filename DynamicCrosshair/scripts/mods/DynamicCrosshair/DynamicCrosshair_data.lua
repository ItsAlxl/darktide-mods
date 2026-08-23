local mod = get_mod("DynamicCrosshair")

return {
	name = "DynamicCrosshair",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id    = "show_ghost_crosshair",
				type          = "checkbox",
				default_value = false,
			},
			{
				setting_id    = "perspectives_reposition",
				type          = "dropdown",
				default_value = 2,
				options       = {
					{ text = "both",    value = 0 },
					{ text = "only_3p", value = 2 },
					{ text = "only_1p", value = 1 },
					{ text = "never",   value = -1 },
				},
			},
			{
				setting_id    = "color_villains",
				type          = "color",
				default_value = { 255, 255, 0, 0 },
				has_alpha     = true,
			},
			{
				setting_id    = "color_heroes",
				type          = "color",
				default_value = { 255, 96, 165, 255 },
				has_alpha     = true,
			},
			{
				setting_id    = "color_props",
				type          = "color",
				default_value = { 255, 255, 165, 0 },
				has_alpha     = true,
			},
			{
				setting_id    = "color_ghost",
				type          = "color",
				default_value = { 96, 216, 229, 207 },
				has_alpha     = true,
			},
		}
	}
}
