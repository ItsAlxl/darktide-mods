local mod = get_mod("Walk")

local walk_speeds = {}
for k, _ in pairs(mod.archetypes) do
	walk_speeds[#walk_speeds + 1] = {
		setting_id      = k,
		type            = "numeric",
		default_value   = 0.5,
		range           = { 0.0, 1.0 },
		decimals_number = 2,
	}
end

return {
	name = "Walk",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id      = "walk_key_toggle",
				type            = "keybind",
				default_value   = {},
				keybind_global  = false,
				keybind_trigger = "pressed",
				keybind_type    = "function_call",
				function_name   = "toggle_walk",
			},
			{
				setting_id      = "walk_key_held",
				type            = "keybind",
				default_value   = {},
				keybind_global  = false,
				keybind_trigger = "held",
				keybind_type    = "function_call",
				function_name   = "held_walk",
			},
			{
				setting_id    = "sprint_cancels",
				type          = "checkbox",
				default_value = true,
			},
			{
				setting_id  = "walk_speed",
				type        = "group",
				sub_widgets = walk_speeds
			}
		}
	}
}
