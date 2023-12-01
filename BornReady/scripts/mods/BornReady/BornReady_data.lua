local mod = get_mod("BornReady")

local party_options = {
	{ text = "none",     value = 0 },
	{ text = "auto_yes", value = 1 },
	{ text = "auto_no",  value = -1 },
}

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id      = "leave_party",
				type            = "keybind",
				default_value   = {},
				keybind_global  = false,
				keybind_trigger = "pressed",
				keybind_type    = "function_call",
				function_name   = "_leave_party",
			},
			{
				setting_id    = "autoskip",
				type          = "checkbox",
				default_value = true,
			},
			{
				setting_id      = "end_skip_time",
				type            = "numeric",
				default_value   = 0.2,
				range           = { 0.0, 10.0 },
				decimals_number = 1,
			},
			{
				setting_id    = "autoready",
				type          = "checkbox",
				default_value = true,
			},
			{
				setting_id    = "automatch",
				type          = "checkbox",
				default_value = true,
			},
			{
				setting_id    = "autojoin",
				type          = "dropdown",
				default_value = 0,
				options       = table.clone(party_options),
			},
			{
				setting_id    = "autowelcome",
				type          = "dropdown",
				default_value = 0,
				options       = party_options,
			},
		}
	}
}
