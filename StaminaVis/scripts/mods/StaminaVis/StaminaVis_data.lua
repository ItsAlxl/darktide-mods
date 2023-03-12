local mod = get_mod("StaminaVis")

return {
	name = "StaminaVis",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "vis_components",
				type = "dropdown",
				default_value = 0,
				options = {
					{ text = "comp_all",  value = 0 },
					{ text = "comp_bar",  value = 1 },
					{ text = "comp_perc", value = 2 },
				},
			},
			{
				setting_id    = "label_vis",
				type          = "checkbox",
				default_value = true,
			},
			{
				setting_id    = "label_flipped",
				type          = "checkbox",
				default_value = true,
			},
			{
				setting_id = "vis_behavior",
				type = "dropdown",
				default_value = 0,
				options = {
					{ text = "behave_normal", value = 0,  show_widgets = { 1, 2, 3, 4 } },
					{ text = "force_visible", value = 1,  show_widgets = {} },
					{ text = "force_hidden",  value = -1, show_widgets = {} },
				},
				sub_widgets = {
					{
						setting_id = "vanish_delay",
						type = "numeric",
						default_value = 2.5,
						range = { 0, 15 },
						decimals_number = 1,
					},
					{
						setting_id = "vanish_speed",
						type = "numeric",
						default_value = 1,
						range = { 0, 10 },
						decimals_number = 1,
					},
					{
						setting_id = "appear_delay",
						type = "numeric",
						default_value = 0,
						range = { 0, 15 },
						decimals_number = 1,
					},
					{
						setting_id = "appear_speed",
						type = "numeric",
						default_value = 0,
						range = { 0, 10 },
						decimals_number = 1,
					},
				}
			},
		}
	}
}
