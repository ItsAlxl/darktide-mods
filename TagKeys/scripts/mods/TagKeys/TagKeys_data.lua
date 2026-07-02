local mod = get_mod("TagKeys")

local create_keybind_option = function(id)
	return {
		setting_id      = "key_" .. id,
		type            = "keybind",
		default_value   = {},
		keybind_global  = false,
		keybind_trigger = "pressed",
		keybind_type    = "function_call",
		function_name   = "_cb_" .. id
	}
end

local widgets = {}
for id, _ in pairs(mod.tags) do
	table.insert(widgets, create_keybind_option(id))
end

return {
	name = "TagKeys",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = widgets
	}
}
