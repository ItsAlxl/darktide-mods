local mod = get_mod("PlaystationPrompts")

local InputLocaleNameOverrides = require("scripts/settings/input/input_locale_name_overrides")

local localization = {
	mod_name = {
		en = " Custom Gamepad Symbols",
	},
	mod_description = {
		en = "Sets the symbols used for gamepad input prompts",
	},
	glyph_style = {
		en = Localize("loc_setting_controller_layout"),
	},
	option_glyph_xbox = {
		en = Localize("loc_platform_name_xbox_live"),
	},
	option_glyph_playstation = {
		en = Localize("loc_platform_name_psn"),
	},
	option_glyph_custom = {
		en = Localize("loc_custom_settings_display_name"),
	},
}

mod.xbox_to_ps = {
	b = "circle",
	y = "triangle",
	x = "square",
	a = "cross",
	back = "touch",
	start = "options",
	left_shoulder = "l1",
	left_trigger = "l2",
	left_thumb = "l3",
	right_shoulder = "r1",
	right_trigger = "r2",
	right_thumb = "r3",
}

local ps4_glyphs = InputLocaleNameOverrides.ps4_controller
for key, glyph in pairs(InputLocaleNameOverrides.xbox_controller) do
	local ps4_key = mod.xbox_to_ps[key]
	local ps4_glyph = ps4_key and ps4_glyphs[ps4_key] or ps4_glyphs[key]

	local loc_text = glyph
	if ps4_glyph then
		loc_text = loc_text .. " / " .. ps4_glyph
	end
	localization["custom_glyph_" .. key] = { en = loc_text }
end

return localization
