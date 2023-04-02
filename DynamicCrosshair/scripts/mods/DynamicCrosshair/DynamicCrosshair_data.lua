local mod = get_mod("DynamicCrosshair")

return {
	name = "DynamicCrosshair",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id    = "compat_custom_color",
				type          = "checkbox",
				default_value = false,
			},
			{
				setting_id  = "group_villains_rgba",
				type        = "group",
				sub_widgets = {
					{
						setting_id = "villains_r",
						type = "numeric",
						title = "red",
						default_value = 255,
						range = { 0, 255 },
					},
					{
						setting_id = "villains_g",
						type = "numeric",
						title = "green",
						default_value = 0,
						range = { 0, 255 },
					},
					{
						setting_id = "villains_b",
						type = "numeric",
						title = "blue",
						default_value = 0,
						range = { 0, 255 },
					},
					{
						setting_id = "villains_a",
						type = "numeric",
						title = "alpha",
						default_value = 255,
						range = { 0, 255 },
					},
				}
			},
			{
				setting_id  = "group_heroes_rgba",
				type        = "group",
				sub_widgets = {
					{
						setting_id = "heroes_r",
						type = "numeric",
						title = "red",
						default_value = 96,
						range = { 0, 255 },
					},
					{
						setting_id = "heroes_g",
						type = "numeric",
						title = "green",
						default_value = 165,
						range = { 0, 255 },
					},
					{
						setting_id = "heroes_b",
						type = "numeric",
						title = "blue",
						default_value = 255,
						range = { 0, 255 },
					},
					{
						setting_id = "heroes_a",
						type = "numeric",
						title = "alpha",
						default_value = 255,
						range = { 0, 255 },
					},
				}
			},
			{
				setting_id  = "group_props_rgba",
				type        = "group",
				sub_widgets = {
					{
						setting_id = "props_r",
						type = "numeric",
						title = "red",
						default_value = 255,
						range = { 0, 255 },
					},
					{
						setting_id = "props_g",
						type = "numeric",
						title = "green",
						default_value = 165,
						range = { 0, 255 },
					},
					{
						setting_id = "props_b",
						type = "numeric",
						title = "blue",
						default_value = 0,
						range = { 0, 255 },
					},
					{
						setting_id = "props_a",
						type = "numeric",
						title = "alpha",
						default_value = 255,
						range = { 0, 255 },
					},
				}
			},
		}
	}
}
