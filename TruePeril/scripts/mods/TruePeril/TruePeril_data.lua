local mod = get_mod("TruePeril")

return {
	name = "TruePeril",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id    = "skip_lerp",
				type          = "checkbox",
				default_value = true,
			},
			{
				setting_id    = "num_decimals",
				type          = "numeric",
				default_value = 0,
				range         = { 0, 2 },
			},
		}
	}
}
