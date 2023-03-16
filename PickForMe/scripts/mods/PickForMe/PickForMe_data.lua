local mod = get_mod("PickForMe")

return {
	name = "PickForMe",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id    = "msg_invalid",
				type          = "checkbox",
				default_value = true,
			},
			{
				setting_id    = "random_character",
				type          = "checkbox",
				default_value = true,
			},
			{
				setting_id  = "quick_randomize",
				type        = "group",
				sub_widgets = {
					{
						setting_id      = "quick_randomize_keybind",
						type            = "keybind",
						default_value   = {},
						keybind_global  = true,
						keybind_trigger = "pressed",
						keybind_type    = "function_call",
						function_name   = "quick_randomize",
					},
					{
						setting_id    = "random_primary",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "random_secondary",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "random_curios",
						type          = "checkbox",
						default_value = false,
					},
					{
						setting_id    = "random_talents",
						type          = "checkbox",
						default_value = false,
					},
				}
			},
		}
	}
}
