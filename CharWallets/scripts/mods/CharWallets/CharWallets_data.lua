local mod = get_mod("CharWallets")

return {
	name = mod:localize("mod_name"),
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
						title         = "currency_credits",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "show_marks",
						title         = "currency_marks",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "show_plasteel",
						title         = "currency_plasteel",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "show_diamantine",
						title         = "currency_diamantine",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "show_contracts",
						title         = "currency_contracts",
						type          = "checkbox",
						default_value = true,
					},
				}
			},
			{
				setting_id  = "options_order",
				type        = "group",
				sub_widgets = {
					{
						setting_id    = "order_credits",
						title          = "currency_credits",
						type          = "numeric",
						default_value = 1,
						range         = { 1, 4 },
					},
					{
						setting_id    = "order_marks",
						title          = "currency_marks",
						type          = "numeric",
						default_value = 2,
						range         = { 1, 4 },
					},
					{
						setting_id    = "order_plasteel",
						title          = "currency_plasteel",
						type          = "numeric",
						default_value = 3,
						range         = { 1, 4 },
					},
					{
						setting_id    = "order_diamantine",
						title          = "currency_diamantine",
						type          = "numeric",
						default_value = 4,
						range         = { 1, 4 },
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
					{
						setting_id    = "contracts_x",
						type          = "numeric",
						default_value = 0,
						range         = { -25, 25 },
					},
				}
			},
		}
	}
}
