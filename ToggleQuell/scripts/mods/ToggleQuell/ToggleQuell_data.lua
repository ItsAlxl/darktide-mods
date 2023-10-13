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
		}
	}
}
