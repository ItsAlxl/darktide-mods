local mod = get_mod("PlaystationPrompts")

local InputLocaleNameOverrides = require("scripts/settings/input/input_locale_name_overrides")

local custom_glyph_widgets = {}

local xbox_glyphs = InputLocaleNameOverrides.xbox_controller
local key_order = {
	"y",
	"b",
	"a",
	"x",
	"d_up",
	"d_right",
	"d_down",
	"d_left",
	"left",
	"left_thumb",
	"right",
	"right_thumb",
	"left_trigger",
	"left_shoulder",
	"right_trigger",
	"right_shoulder",
	"back",
	"start"
}
for _, key in ipairs(key_order) do
	custom_glyph_widgets[#custom_glyph_widgets + 1] = {
		setting_id      = key,
		title           = "custom_glyph_" .. key,
		type            = "text_input",
		default_value   = { xbox_glyphs[key] },
		function_name   = "_junk_textbox_cb",
		keybind_type    = "function_call",
		keybind_trigger = "pressed",
	}
end

-- tbh I have no idea why DMF requires text boxes to have callbacks
mod._junk_textbox_cb = function() end

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id    = "glyph_style",
				type          = "dropdown",
				default_value = "playstation",
				options       = {
					{ text = "option_glyph_xbox",        value = "xbox" },
					{ text = "option_glyph_playstation", value = "playstation" },
					{ text = "option_glyph_custom",      value = "custom" },
				},
			},
			{
				setting_id  = "option_glyph_custom",
				type        = "group",
				sub_widgets = custom_glyph_widgets
			}
		}
	}
}
