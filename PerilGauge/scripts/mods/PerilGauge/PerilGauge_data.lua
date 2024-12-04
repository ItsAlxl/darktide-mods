local mod = get_mod("PerilGauge")

local vert_options = {
	{ text = "vert_top", value = -1 },
	{ text = "vert_center", value = 0 },
	{ text = "vert_bottom", value = 1 },
}
local horiz_options = {
	{ text = "horiz_left", value = -1 },
	{ text = "horiz_center", value = 0 },
	{ text = "horiz_right", value = 1 },
}

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = false,
	options = {
		widgets = {
			{
				setting_id = "gauge_thick",
				type = "numeric",
				default_value = 15,
				range = { 5, 50 },
				decimals_number = 0,
			},
			{
				setting_id = "gauge_length",
				type = "numeric",
				default_value = 210,
				range = { 100, 450 },
				decimals_number = 0,
			},
			{
				setting_id = "gauge_alpha",
				type = "numeric",
				default_value = 1,
				range = { 0, 1 },
				decimals_number = 2,
			},
			{
				setting_id = "wep_counter_behavior",
				type = "dropdown",
				default_value = 0,
				options = {
					{ text = "counter_use_counter", value = 0 },
					{ text = "counter_use_gauge", value = 1 },
					{ text = "counter_use_both", value = 2 },
				},
			},
			{
				setting_id = "vis_behavior",
				type = "dropdown",
				default_value = 0,
				options = {
					{ text = "behave_normal", value = 0, show_widgets = { 1, 2, 3, 4 } },
					{ text = "force_visible", value = 1, show_widgets = {} },
					{ text = "force_hidden", value = -1, show_widgets = {} },
				},
				sub_widgets = {
					{
						setting_id = "vanish_delay",
						type = "numeric",
						default_value = 1.5,
						range = { 0, 15 },
						decimals_number = 1,
					},
					{
						setting_id = "vanish_speed",
						type = "numeric",
						default_value = 5,
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
						default_value = 5,
						range = { 0, 10 },
						decimals_number = 1,
					},
				}
			},
			{
				setting_id = "group_vanilla_text",
				type = "group",
				sub_widgets = {
					{
						setting_id = "override_peril_color",
						title = "override_color",
						type = "checkbox",
						default_value = false,
					},
					{
						setting_id = "override_peril_alpha",
						title = "override_alpha",
						type = "checkbox",
						default_value = false,
					},
					{
						setting_id = "override_peril_text",
						title = "override_text",
						type = "checkbox",
						default_value = true,
					},
					{
						setting_id = "vanilla_alpha_mult",
						title = "alpha_mult",
						type = "numeric",
						default_value = 1,
						range = { 0, 1 },
						decimals_number = 2,
					},
				}
			},
			{
				setting_id = "group_comps",
				type = "group",
				sub_widgets = {
					{
						setting_id = "comp_bracket",
						type = "checkbox",
						default_value = true,
					},
					{
						setting_id = "lbl_text",
						type = "dropdown",
						default_value = "lbl_text_flame",
						options = {
							{ text = "lbl_text_none", value = "lbl_text_none" },
							{ text = "lbl_text_peril", value = "lbl_text_peril" },
							{ text = "lbl_text_skull", value = "lbl_text_skull" },
							{ text = "lbl_text_flame", value = "lbl_text_flame" },
						},
					},
					{
						setting_id = "show_perc",
						type = "checkbox",
						default_value = false,
					},
					{
						setting_id = "perc_num_decimals",
						type = "numeric",
						default_value = 1,
						range = { 0, 2 },
					},
					{
						setting_id = "perc_lead_zeroes",
						type = "numeric",
						default_value = 1,
						range = { 0, 2 },
					},
					{
						setting_id = "comp_orientation",
						type = "dropdown",
						default_value = 0,
						options = {
							{ text = "orientation_horizontal", value = 0 },
							{ text = "orientation_vertical", value = 1 },
							{ text = "orientation_horizontal_flipped", value = 2 },
							{ text = "orientation_vertical_flipped", value = 3 },
						},
					},
					{
						setting_id = "bar_direction",
						type = "dropdown",
						default_value = 1,
						options = {
							{ text = "bar_dir_start", value = 1 },
							{ text = "bar_dir_end", value = 2 },
							{ text = "bar_dir_center", value = 3 },
						},
					},
					{
						setting_id = "lbl_vert",
						tooltip = "vert_hint",
						type = "dropdown",
						default_value = 1,
						options = vert_options,
					},
					{
						setting_id = "lbl_horiz",
						tooltip = "horiz_hint",
						type = "dropdown",
						default_value = 1,
						options = horiz_options,
					},
					{
						setting_id = "perc_vert",
						tooltip = "vert_hint",
						type = "dropdown",
						default_value = 1,
						options = table.clone(vert_options),
					},
					{
						setting_id = "perc_horiz",
						tooltip = "horiz_hint",
						type = "dropdown",
						default_value = -1,
						options = table.clone(horiz_options),
					},
				}
			},
		}
	}
}
