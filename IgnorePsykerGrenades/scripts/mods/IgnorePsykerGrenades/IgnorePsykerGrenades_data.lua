local mod = get_mod("IgnorePsykerGrenades")

return {
	name =  mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id    = "psyker_throwing_knives",
				type          = "checkbox",
				default_value = true,
			},
			{
				setting_id    = "psyker_smite",
				type          = "checkbox",
				default_value = true,
			},
			{
				setting_id    = "psyker_chain_lightning",
				type          = "checkbox",
				default_value = true,
			},
		}
	}
}
