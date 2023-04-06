local mod = get_mod("AimSensitivity")

return {
	name = "AimSensitivity",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id      = "aim_sensitivity_mult",
				type            = "numeric",
				default_value   = 1.0,
				range           = { 0.0, 2.0 },
				decimals_number = 2
			}
		}
	}
}
