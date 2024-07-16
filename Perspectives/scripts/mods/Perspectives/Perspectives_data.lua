local mod = get_mod("Perspectives")

local autoswitch_options = {
	{ text = "autoswitch_to_none",  value = 0 },
	{ text = "autoswitch_to_first", value = 1 },
	{ text = "autoswitch_to_third", value = 2 },
}

local xhair_options = {}
for _, type in ipairs(mod._xhair_types) do
	table.insert(xhair_options, {
		text = "xhair_" .. type,
		value = type,
	})
end

return {
	name = "Perspectives",
	description = mod:localize("mod_description"),
	is_togglable = false,
	options = {
		widgets = {
			{
				setting_id    = "allow_switching",
				type          = "checkbox",
				default_value = true,
			},
			{
				setting_id      = "third_person_toggle",
				type            = "keybind",
				default_value   = {},
				keybind_global  = false,
				keybind_trigger = "pressed",
				keybind_type    = "function_call",
				function_name   = "kb_toggle_third_person",
			},
			{
				setting_id      = "third_person_held",
				type            = "keybind",
				default_value   = {},
				keybind_global  = false,
				keybind_trigger = "held",
				keybind_type    = "function_call",
				function_name   = "kb_toggle_third_person",
			},
			{
				setting_id      = "perspective_transition_time",
				type            = "numeric",
				default_value   = 0.1,
				range           = { 0.0, 1.0 },
				decimals_number = 2,
			},
			{
				setting_id    = "default_perspective_mode",
				type          = "dropdown",
				default_value = 0,
				options       = {
					{ text = "defper_normal",       value = 0 },
					{ text = "defper_swapped",      value = -1 },
					{ text = "defper_always_first", value = 1 },
					{ text = "defper_always_third", value = 2 },
				},
			},
			{
				setting_id  = "group_3p_behavior",
				type        = "group",
				sub_widgets = {
					{
						setting_id      = "cycle_shoulder",
						type            = "keybind",
						default_value   = {},
						keybind_global  = false,
						keybind_trigger = "pressed",
						keybind_type    = "function_call",
						function_name   = "kb_cycle_shoulder",
					},
					{
						setting_id    = "aim_mode",
						type          = "dropdown",
						default_value = 0,
						options       = {
							{ text = "viewpoint_1p",     value = -1 },
							{ text = "viewpoint_cycle",  value = 0 },
							{ text = "viewpoint_center", value = 1 },
							{ text = "viewpoint_right",  value = 2 },
							{ text = "viewpoint_left",   value = 3 },
						},
					},
					{
						setting_id    = "nonaim_mode",
						type          = "dropdown",
						default_value = 0,
						options       = {
							{ text = "viewpoint_cycle",  value = 0 },
							{ text = "viewpoint_center", value = 1 },
							{ text = "viewpoint_right",  value = 2 },
							{ text = "viewpoint_left",   value = 3 },
						},
					},
					{
						setting_id    = "cycle_includes_center",
						type          = "checkbox",
						default_value = false,
					},
					{
						setting_id    = "center_to_1p_human",
						type          = "checkbox",
						tooltip       = "center_to_1p_description",
						default_value = false,
					},
					{
						setting_id    = "center_to_1p_ogryn",
						type          = "checkbox",
						tooltip       = "center_to_1p_description",
						default_value = true,
					},
					{
						setting_id    = "xhair_fallback",
						type          = "dropdown",
						default_value = "assault",
						options       = xhair_options,
					},
					{
						setting_id    = "use_lookaround_node",
						type          = "checkbox",
						default_value = true,
					},
				},
			},
			{
				setting_id  = "group_custom_viewpoint",
				type        = "group",
				sub_widgets = {
					{
						setting_id      = "custom_distance",
						type            = "numeric",
						default_value   = 0.0,
						range           = { -1.0, 1.0 },
						decimals_number = 2,
					},
					{
						setting_id      = "custom_offset",
						type            = "numeric",
						default_value   = 0.0,
						range           = { -1.0, 1.0 },
						decimals_number = 2,
					},
					{
						setting_id      = "custom_distance_zoom",
						type            = "numeric",
						tooltip         = "custom_distance_description",
						default_value   = 0.0,
						range           = { -1.0, 1.0 },
						decimals_number = 2,
					},
					{
						setting_id      = "custom_offset_zoom",
						type            = "numeric",
						tooltip         = "custom_offset_description",
						default_value   = 0.0,
						range           = { -1.0, 1.0 },
						decimals_number = 2,
					},
					{
						setting_id      = "custom_distance_ogryn",
						type            = "numeric",
						default_value   = 0.0,
						range           = { -1.0, 1.0 },
						decimals_number = 2,
					},
					{
						setting_id      = "custom_offset_ogryn",
						type            = "numeric",
						default_value   = 0.0,
						range           = { -1.0, 1.0 },
						decimals_number = 2,
					},
				}
			},
			{
				setting_id  = "group_autoswitch",
				type        = "group",
				sub_widgets = {
					{
						setting_id    = "autoswitch_slot_device",
						type          = "dropdown",
						default_value = 1,
						options       = autoswitch_options,
					},
					{
						setting_id    = "autoswitch_spectate",
						type          = "dropdown",
						default_value = 2,
						options       = table.clone(autoswitch_options),
					},
					{
						setting_id    = "autoswitch_slot_primary",
						type          = "dropdown",
						default_value = 0,
						options       = table.clone(autoswitch_options),
					},
					{
						setting_id    = "autoswitch_slot_secondary",
						type          = "dropdown",
						default_value = 0,
						options       = table.clone(autoswitch_options),
					},
					{
						setting_id    = "autoswitch_slot_grenade_ability",
						type          = "dropdown",
						default_value = 0,
						options       = table.clone(autoswitch_options),
					},
					{
						setting_id    = "autoswitch_slot_pocketable",
						type          = "dropdown",
						default_value = 0,
						options       = table.clone(autoswitch_options),
					},
					{
						setting_id    = "autoswitch_slot_pocketable_small",
						type          = "dropdown",
						default_value = 0,
						options       = table.clone(autoswitch_options),
					},
					{
						setting_id    = "autoswitch_slot_luggable",
						type          = "dropdown",
						default_value = 0,
						options       = table.clone(autoswitch_options),
					},
					{
						setting_id    = "autoswitch_slot_unarmed",
						type          = "dropdown",
						default_value = 0,
						options       = table.clone(autoswitch_options),
					},
					{
						setting_id    = "autoswitch_sprint",
						type          = "dropdown",
						default_value = 0,
						options       = table.clone(autoswitch_options),
					},
					{
						setting_id    = "autoswitch_lunge_ogryn",
						type          = "dropdown",
						default_value = 0,
						options       = table.clone(autoswitch_options),
					},
					{
						setting_id    = "autoswitch_lunge_human",
						type          = "dropdown",
						default_value = 0,
						options       = table.clone(autoswitch_options),
					},
					{
						setting_id    = "autoswitch_act2_primary",
						type          = "dropdown",
						default_value = 0,
						options       = table.clone(autoswitch_options),
					},
					{
						setting_id    = "autoswitch_act2_secondary",
						type          = "dropdown",
						default_value = 0,
						options       = table.clone(autoswitch_options),
					},
				},
			},
		}
	}
}
