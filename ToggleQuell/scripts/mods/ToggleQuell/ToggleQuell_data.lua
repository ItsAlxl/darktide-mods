local mod = get_mod("ToggleQuell")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id      = "toggle_timing",
				type            = "numeric",
				default_value   = 0,
				range           = { 0, 2.5 },
				decimals_number = 1
			},
			{
				setting_id  = "optgroup_untoggle_acts",
				type        = "group",
				sub_widgets = {
					{
						setting_id    = "action_one_pressed",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "action_two_pressed",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "weapon_extra_pressed",
						type          = "checkbox",
						default_value = true,
					},
				}
			},
		}
	}
}
