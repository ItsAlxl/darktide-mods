local mod = get_mod("StaminaVis")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
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
			{
				setting_id  = "group_base_comps",
				type        = "group",
				sub_widgets = {
					{
						setting_id    = "comp_base_bar",
						type          = "checkbox",
						title         = "comp_bar",
						default_value = true,
					},
					{
						setting_id    = "comp_base_bracket",
						type          = "checkbox",
						title         = "comp_bracket",
						default_value = true,
					},
					{
						setting_id    = "comp_base_lbl",
						type          = "checkbox",
						title         = "comp_lbl",
						default_value = true,
					},
					{
						setting_id    = "comp_base_perc",
						type          = "checkbox",
						title         = "comp_perc",
						default_value = true,
					},
					{
						setting_id    = "comp_base_flip",
						type          = "checkbox",
						title         = "comp_flip",
						default_value = false,
					},
				}
			},
			{
				setting_id  = "group_melee_comps",
				type        = "group",
				sub_widgets = {
					{
						setting_id    = "use_melee_override",
						type          = "checkbox",
						default_value = false,
						sub_widgets   = {
							{
								setting_id    = "comp_melee_bar",
								type          = "checkbox",
								title         = "comp_bar",
								default_value = true,
							},
							{
								setting_id    = "comp_melee_bracket",
								type          = "checkbox",
								title         = "comp_bracket",
								default_value = true,
							},
							{
								setting_id    = "comp_melee_lbl",
								type          = "checkbox",
								title         = "comp_lbl",
								default_value = true,
							},
							{
								setting_id    = "comp_melee_perc",
								type          = "checkbox",
								title         = "comp_perc",
								default_value = true,
							},
							{
								setting_id    = "comp_melee_flip",
								type          = "checkbox",
								title         = "comp_flip",
								default_value = false,
							},
						}
					},
				}
			},
		}
	}
}
