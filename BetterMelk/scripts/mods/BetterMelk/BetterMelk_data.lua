local mod = get_mod("BetterMelk")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id    = "notify_new",
				type          = "checkbox",
				default_value = false,
			},
			{
				setting_id    = "notify_done",
				type          = "checkbox",
				default_value = true,
			},
			{
				setting_id    = "notif_mode",
				type          = "dropdown",
				default_value = 1,
				options       = {
					{ text = "channel_both",   value = 0 },
					{ text = "channel_chat",   value = 1 },
					{ text = "channel_notifs", value = 2 },
				},
			},
		}
	}
}
