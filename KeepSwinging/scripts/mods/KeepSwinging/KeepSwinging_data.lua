local mod = get_mod("KeepSwinging")

return {
	name = "KeepSwinging",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id  = "group_select",
				type        = "group",
				sub_widgets = {
					{
						setting_id      = "pressed_keybind",
						type            = "keybind",
						default_value   = {},
						keybind_global  = false,
						keybind_trigger = "pressed",
						keybind_type    = "function_call",
						function_name   = "_toggle_swinging",
					},
					{
						setting_id      = "held_keybind",
						type            = "keybind",
						default_value   = {},
						keybind_global  = false,
						keybind_trigger = "held",
						keybind_type    = "function_call",
						function_name   = "_toggle_swinging",
					},
					{
						setting_id    = "default_mode",
						type          = "checkbox",
						default_value = false,
					},
					{
						setting_id    = "as_modifier",
						type          = "checkbox",
						default_value = false,
					},
				}
			},
			{
				setting_id  = "group_attack_types",
				type        = "group",
				sub_widgets = {
					{
						setting_id    = "include_melee_primary",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "include_melee_specials",
						type          = "checkbox",
						default_value = false,
					},
					{
						setting_id    = "include_ranged_specials",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "include_gauntlets",
						type          = "checkbox",
						default_value = true,
					},
				}
			},
			{
				setting_id  = "group_hud",
				title       = "hud_element",
				type        = "group",
				sub_widgets = {
					{
						setting_id    = "hud_element",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id = "hud_element_size",
						type = "numeric",
						default_value = 50,
						range = { 10, 80 },
					},
				}
			},
			{
				setting_id  = "group_disable_acts",
				type        = "group",
				sub_widgets = {
					{
						setting_id    = "persist_after_disable",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "disable_action_one_hold",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "disable_action_two_hold",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "disable_weapon_reload_hold",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "disable_weapon_extra_hold",
						type          = "checkbox",
						default_value = true,
					},
				}
			},
		}
	}
}
