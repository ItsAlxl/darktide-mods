local mod = get_mod("InventoryStats")

return {
	name = "InventoryStats",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id    = "force_equip",
				type          = "checkbox",
				default_value = true,
			},
			{
				setting_id  = "g_stat_toggles",
				type        = "group",
				sub_widgets = {
					{
						setting_id    = "health",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "wounds",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "toughness",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "stamina",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "stamina_regen",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "crit_chance",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "crit_dmg",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "sprint_speed",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "sprint_time",
						type          = "checkbox",
						default_value = true,
					},
				}
			},
		}
	}
}
