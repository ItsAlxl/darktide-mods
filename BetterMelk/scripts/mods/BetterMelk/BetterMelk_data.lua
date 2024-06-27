local mod = get_mod("BetterMelk")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id    = "offset_x",
				type          = "numeric",
				default_value = 0,
				range         = { -20, 350 },
			},
			{
				setting_id    = "offset_y",
				type          = "numeric",
				default_value = 0,
				range         = { -10, 80 },
			},
		}
	}
}
