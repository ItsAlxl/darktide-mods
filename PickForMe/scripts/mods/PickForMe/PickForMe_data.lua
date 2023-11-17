local mod = get_mod("PickForMe")

local quick_randomize_subwidgets = {
	{
		setting_id      = "quick_randomize_keybind",
		type            = "keybind",
		default_value   = {},
		keybind_global  = true,
		keybind_trigger = "pressed",
		keybind_type    = "function_call",
		function_name   = "quick_randomize",
	},
}

for _, arg in ipairs(mod.arg_order) do
	if mod.slot_data[arg] then
		table.insert(quick_randomize_subwidgets, {
			setting_id    = arg,
			type          = "checkbox",
			default_value = mod.slot_data[arg].default or false,
		})
	end
end

return {
	name = "PickForMe",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id    = "msg_invalid",
				type          = "checkbox",
				default_value = true,
			},
			{
				setting_id    = "random_character",
				type          = "checkbox",
				default_value = true,
			},
			{
				setting_id  = "quick_randomize",
				type        = "group",
				sub_widgets = quick_randomize_subwidgets
			},
		}
	}
}
