local mod = get_mod("MissionBrief")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "show_mission",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "show_fluff",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "ui_scale",
				type = "numeric",
				default_value = 1.0,
				range = { 0.1, 2.0 },
				decimals_number = 2,
			},
			{
				setting_id = "panel_width",
				type = "numeric",
				default_value = 500,
				range = { 100, 900 },
				decimals_number = 0,
			},
			{
				setting_id = "panel_alpha",
				type = "numeric",
				default_value = 255,
				range = { 0, 255 },
				decimals_number = 0,
			},
		}
	}
}
