local mod = get_mod("GoToMastery")

local keybind_widgets = {}
local widget_order = {
	"kb_marks",
	"kb_cosmetics",
	"kb_inspect",
	"kb_mastery",
	"kb_hadron",
}
for _, key in ipairs(widget_order) do
	local data = mod.hotkey_data[key]
	data.function_name = "_" .. key
	keybind_widgets[#keybind_widgets + 1] = {
		setting_id = key,
		type = "keybind",
		default_value = data.default or {},
		keybind_global  = true,
		keybind_trigger = "pressed",
		keybind_type = "function_call",
		function_name = data.function_name,
	}
end

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = keybind_widgets,
	}
}
