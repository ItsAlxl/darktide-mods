local mod = get_mod("TalentRefundBelow")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "mode_remove_below",
				type = "dropdown",
				default_value = 1,
				options = {
					{ text = "mode_never", value = 0 },
					{ text = "mode_single", value = 1 },
					{ text = "mode_double", value = 2 },
				}
			},
			{
				setting_id = "mode_exclusive_swap",
				type = "dropdown",
				default_value = 2,
				options = {
					{ text = "mode_never", value = 0 },
					{ text = "mode_single", value = 1 },
					{ text = "mode_double", value = 2 },
				}
			},
			{
				setting_id    = "swap_siblings",
				type          = "checkbox",
				default_value = true,
			},
			{
				setting_id      = "double_click_window",
				type            = "numeric",
				default_value   = 0.5,
				range           = { 0.1, 2.0 },
				decimals_number = 1,
			},
		}
	}
}
