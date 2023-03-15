local mod = get_mod("Tap2Dodge")

return {
	name = "Tap2Dodge",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id      = "max_delay",
				type            = "numeric",
				default_value   = 0.3,
				range           = { 0.15, 1.5 },
				decimals_number = 2
			},
			{
				setting_id      = "action_threshold",
				type            = "numeric",
				default_value   = 0.7,
				range           = { 0.01, 1.0 },
				decimals_number = 2
			},
		}
	}
}
