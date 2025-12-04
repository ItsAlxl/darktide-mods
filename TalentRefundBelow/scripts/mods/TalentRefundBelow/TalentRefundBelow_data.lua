local mod = get_mod("TalentRefundBelow")

local _create_click_options = function()
	return {
		{ text = "mode_never",  value = 0 },
		{ text = "mode_single", value = 1 },
		{ text = "mode_double", value = 2 },
	}
end

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "remove_dependents",
				type = "dropdown",
				default_value = 2,
				options = _create_click_options()
			},
			{
				setting_id = "swap_exclusives",
				type = "dropdown",
				default_value = 2,
				options = _create_click_options()
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
