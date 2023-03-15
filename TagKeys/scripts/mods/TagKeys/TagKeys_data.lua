local mod = get_mod("TagKeys")

local ping_types = {
	"thanks",
	"need_health",
	"enemy",
	"location",
	"attention",
	"need_ammo",
}

local keybind_template = {
	setting_id      = "",
	type            = "keybind",
	default_value   = {},
	keybind_global  = false,
	keybind_trigger = "pressed",
	keybind_type    = "function_call",
	function_name   = ""
}

local widgets = {}

for idx, t in pairs(ping_types) do
	table.insert(widgets, table.clone(keybind_template))
	widgets[idx].setting_id = "key_" .. t
	widgets[idx].function_name = "tag_" .. t
end

return {
	name = "TagKeys",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = widgets
	}
}
