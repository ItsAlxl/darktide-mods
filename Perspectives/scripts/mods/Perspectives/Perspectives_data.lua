local mod = get_mod("Perspectives")

local autoswitch_options = {
	{ text = "autoswitch_none",  value = 0 },
	{ text = "autoswitch_first", value = 1 },
	{ text = "autoswitch_third", value = 2 },
}

return {
	name = "Perspectives",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
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
				decimals_number = 1,
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
				setting_id    = "third_person_spectate",
				type          = "checkbox",
				default_value = false,
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
						setting_id    = "use_lookaround_node",
						type          = "checkbox",
						default_value = true,
					},
				},
			},
			{
				setting_id  = "group_autoswitch",
				type        = "group",
				sub_widgets = {
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
						setting_id    = "autoswitch_slot_luggable",
						type          = "dropdown",
						default_value = 0,
						options       = table.clone(autoswitch_options),
					},
				},
			},
		}
	}
}
