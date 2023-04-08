local mod = get_mod("ToggleInteract")

return {
	name = "ToggleInteract",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id    = "interact_cancel",
				type          = "checkbox",
				default_value = true,
			},
			{
				setting_id    = "ephemeral_cancel",
				type          = "checkbox",
				default_value = true,
			},
			{
				setting_id    = "replace_tooltip",
				type          = "checkbox",
				default_value = true,
			},
		}
	}
}
