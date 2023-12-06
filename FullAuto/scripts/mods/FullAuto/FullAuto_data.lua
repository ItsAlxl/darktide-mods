local mod = get_mod("FullAuto")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id  = "group_select",
				type        = "group",
				sub_widgets = {
					{
						setting_id      = "pressed_autoshoot",
						type            = "keybind",
						default_value   = {},
						keybind_global  = false,
						keybind_trigger = "pressed",
						keybind_type    = "function_call",
						function_name   = "_toggle_select",
					},
					{
						setting_id      = "held_autoshoot",
						type            = "keybind",
						default_value   = {},
						keybind_global  = false,
						keybind_trigger = "held",
						keybind_type    = "function_call",
						function_name   = "_toggle_select",
					},
					{
						setting_id    = "default_autofire",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "remember_per_wep",
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
						default_value = 56,
						range = { 10, 80 },
					},
				}
			},
			{
				setting_id  = "group_extra",
				type        = "group",
				sub_widgets = {
					{
						setting_id    = "shoot_for_me",
						type          = "checkbox",
						default_value = false,
					},
					{
						setting_id    = "include_psyker_bees",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "chargeup_autofire",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id      = "chargeup_autofire_amt",
						type            = "numeric",
						default_value   = 100,
						range           = { 0, 100 },
						decimals_number = 0,
					},
				}
			},
		}
	}
}
