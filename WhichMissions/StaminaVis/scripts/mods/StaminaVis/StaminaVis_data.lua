local mod = get_mod("StaminaVis")

return {
	name = "StaminaVis",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "vis_behavior",
				type = "dropdown",
				default_value = 0,
				options = {
					{ text = "behave_normal", value = 0, show_widgets = { 1, 2, 3, 4 } },
					{ text = "force_visible", value = 1, show_widgets = { } },
					{ text = "force_hidden",  value = -1, show_widgets = { } },
				},
				sub_widgets = {
					{
						setting_id = "vanish_delay",
						tooltip = "vanish_delay_hint",
						type = "numeric",
						default_value = 2.5,
						range = { 0, 15 },
						decimals_number = 1,
					},
					{
						setting_id = "vanish_speed",
						tooltip = "vanish_speed_hint",
						type = "numeric",
						default_value = 1,
						range = { 0, 10 },
						decimals_number = 1,
					},
					{
						setting_id = "appear_delay",
						tooltip = "appear_delay_hint",
						type = "numeric",
						default_value = 0,
						range = { 0, 15 },
						decimals_number = 1,
					},
					{
						setting_id = "appear_speed",
						tooltip = "appear_speed_hint",
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
