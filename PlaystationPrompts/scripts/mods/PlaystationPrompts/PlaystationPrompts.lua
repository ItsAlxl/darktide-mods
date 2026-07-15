local mod = get_mod("PlaystationPrompts")

local InputLocaleNameOverrides = require("scripts/settings/input/input_locale_name_overrides")

local xbox_glyphs = InputLocaleNameOverrides.xbox_controller
local ps4_glyphs = InputLocaleNameOverrides.ps4_controller
local custom_glyphs = mod:persistent_table("custom_glyphs")

local set_glyph = function(key, glyph)
	custom_glyphs[key] = glyph
	local ps4_key = mod.xbox_to_ps[key] or ps4_glyphs[key] and key
	if ps4_key then
		custom_glyphs[ps4_key] = glyph
	end
end

local reapply_overrides = function()
	local input_manager = Managers and Managers.input
	if input_manager then
		for _, device in ipairs(input_manager._all_input_devices) do
			input_manager:_locale_override(device:raw_device(), InputLocaleNameOverrides[device.device_type])
		end
	end
end

mod:hook(CLASS.InputManager, "_locale_override", function(func, self, raw_device, overrides, ...)
	return func(self, raw_device, custom_glyphs, ...)
end)

mod.on_setting_changed = function(id)
	local style = mod:get("glyph_style")
	if id == "glyph_style" then
		if style == "xbox" then
			for key, glyph in pairs(xbox_glyphs) do
				set_glyph(key, glyph)
			end
		elseif style == "playstation" then
			for key, glyph in pairs(xbox_glyphs) do
				local ps4_key = mod.xbox_to_ps[key]
				set_glyph(key, ps4_key and ps4_glyphs[ps4_key] or ps4_glyphs[key] or glyph)
			end
		else
			for key, _ in pairs(xbox_glyphs) do
				set_glyph(key, mod:get(key))
			end
		end
		reapply_overrides()
	elseif style == "custom" then
		set_glyph(id, mod:get(id))
		reapply_overrides()
	end
end

mod.on_enabled = function()
	mod.on_setting_changed("glyph_style")
end

mod.on_disabled = function()
	reapply_overrides()
end
