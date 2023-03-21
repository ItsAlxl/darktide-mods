local mod = get_mod("KeepSwinging")

return {
	name = "KeepSwinging",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
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
				setting_id      = "pressed_keybind",
				type            = "keybind",
				default_value   = {},
				keybind_global  = false,
				keybind_trigger = "pressed",
				keybind_type    = "function_call",
				function_name   = "_toggle_swinging",
			},
			{
				setting_id    = "as_modifier",
				type          = "checkbox",
				default_value = false,
			},
			{
				setting_id    = "wield_default",
				type          = "checkbox",
				default_value = false,
			},
			{
				setting_id  = "group_disable_acts",
				type        = "group",
				sub_widgets = {
					{
						setting_id    = "disable_after_action_one",
						type          = "checkbox",
						default_value = false,
					},
					{
						setting_id    = "disable_after_action_two",
						type          = "checkbox",
						default_value = false,
					},
					{
						setting_id    = "disable_after_weapon_reload",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "disable_after_weapon_extra",
						type          = "checkbox",
						default_value = false,
					},
				}
			},
		}
	}
}
