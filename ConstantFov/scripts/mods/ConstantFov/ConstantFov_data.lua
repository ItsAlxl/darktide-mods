local mod = get_mod("ConstantFov")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id  = "group_toggles",
				type        = "group",
				sub_widgets = {
					{
						setting_id    = "allow_aim",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "allow_sprint",
						type          = "checkbox",
						default_value = false,
					},
					{
						setting_id    = "allow_lunge",
						type          = "checkbox",
						default_value = false,
					},
					{
						setting_id    = "allow_vetult",
						type          = "checkbox",
						default_value = false,
					},
				}
			},
			{
				setting_id  = "group_tweaks",
				type        = "group",
				sub_widgets = {
					{
						setting_id      = "change_multiplier",
						type            = "numeric",
						default_value   = 1.0,
						range           = { 0.0, 2.0 },
						decimals_number = 2
					},
					{
						setting_id      = "limit_lower",
						type            = "numeric",
						default_value   = 0.0,
						range           = { 0.0, 1.0 },
						decimals_number = 2
					},
					{
						setting_id      = "limit_upper",
						type            = "numeric",
						default_value   = 2.0,
						range           = { 1.0, 2.0 },
						decimals_number = 2
					},
					{
						setting_id    = "apply_baseline",
						type          = "checkbox",
						default_value = true,
					},
				}
			},
		}
	}
}
