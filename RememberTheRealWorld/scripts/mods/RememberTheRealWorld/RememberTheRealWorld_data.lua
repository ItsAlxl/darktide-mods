local mod = get_mod("RememberTheRealWorld")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id      = "reminder_interval",
				type            = "numeric",
				default_value   = 90,
				range           = { 5, 300 },
				decimals_number = 0,
				step_size_value = 5
			},
			{
				setting_id      = "reminder_duration",
				type            = "numeric",
				default_value   = 10,
				range           = { 0, 180 },
				decimals_number = 0,
				step_size_value = 5
			},
		}
	}
}
