local mod = get_mod("CharWallets")

return {
	name = "CharWallets",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id  = "options_vis",
				type        = "group",
				sub_widgets = {
					{
						setting_id    = "show_credits",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "show_marks",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "show_plasteel",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "show_diamantine",
						type          = "checkbox",
						default_value = true,
					},
				}
			},
			{
				setting_id  = "options_spacing",
				type        = "group",
				sub_widgets = {
					{
						setting_id    = "start_x",
						type          = "numeric",
						default_value = 0,
						range         = { -25, 25 },
					},
					{
						setting_id    = "size_x",
						type          = "numeric",
						default_value = 0,
						range         = { -50, 50 },
					},
				}
			},
		}
	}
}
