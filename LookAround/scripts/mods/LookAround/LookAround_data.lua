local mod = get_mod("LookAround")

return {
	name = "LookAround",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id      = "freelook",
				type            = "keybind",
				default_value   = {},
				keybind_global  = false,
				keybind_trigger = "pressed",
				keybind_type    = "function_call",
				function_name   = "kb_freelook_toggle",
			},
			{
				setting_id      = "freelook_held",
				type            = "keybind",
				default_value   = {},
				keybind_global  = false,
				keybind_trigger = "held",
				keybind_type    = "function_call",
				function_name   = "kb_freelook_held",
			},
			{
				setting_id    = "clamp_pitch",
				type          = "checkbox",
				default_value = true,
			},
			{
				setting_id      = "clamp_yaw_normal",
				tooltip         = "clamp_zero_hint",
				type            = "numeric",
				default_value   = 0,
				range           = { 0, 120 },
				decimals_number = 0
			},
			{
				setting_id      = "clamp_yaw_spectate",
				tooltip         = "clamp_zero_hint",
				type            = "numeric",
				default_value   = 0,
				range           = { 0, 120 },
				decimals_number = 0
			},
			{
				setting_id    = "auto_on_spectate",
				type          = "checkbox",
				default_value = false,
			},
			{
				setting_id      = "lerp_duration",
				type            = "numeric",
				default_value   = 0.18,
				range           = { 0, 1.0 },
				decimals_number = 2
			},
			{
				setting_id      = "sensitivity_mouse",
				type            = "numeric",
				default_value   = 1.0,
				range           = { 0.05, 2.0 },
				decimals_number = 2
			},
			{
				setting_id      = "sensitivity_controller",
				type            = "numeric",
				default_value   = 1.0,
				range           = { 0.05, 2.0 },
				decimals_number = 2
			}
		}
	}
}
