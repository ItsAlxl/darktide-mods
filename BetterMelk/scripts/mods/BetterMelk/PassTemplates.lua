local mod = get_mod("BetterMelk")

local UIFontSettings = require("scripts/managers/ui/ui_font_settings")

local CONTRACTS_TEXT_OFFSET = { 20, 10, 100 }

mod:hook_require("scripts/ui/pass_templates/character_select_pass_templates", function(CharacterSelectPassTemplates)
	local character_select = CharacterSelectPassTemplates.character_select

	local get_pass_by_style_id = function(id)
		for i = 1, #character_select do
			local pass = character_select[i]
			if pass.style_id == id then
				return pass
			end
		end
		return nil
	end

	local character_archetype_title_pass = get_pass_by_style_id("character_archetype_title")
	local contracts_text_style
	if character_archetype_title_pass then
		contracts_text_style = table.clone(character_archetype_title_pass.style)
	else
		contracts_text_style = table.clone(UIFontSettings.body_small)
		contracts_text_style.text_color = Color.terminal_text_body_sub_header(255, true)
		contracts_text_style.default_color = Color.terminal_text_body_sub_header(255, true)
		contracts_text_style.hover_color = Color.terminal_text_header(255, true)
	end
	contracts_text_style.text_horizontal_alignment = "right"
	contracts_text_style.text_vertical_alignment = "top"
	contracts_text_style.horizontal_alignment = "right"
	contracts_text_style.vertical_alignment = "top"
	contracts_text_style.size = { 150, 20 }
	contracts_text_style.offset = CONTRACTS_TEXT_OFFSET
	contracts_text_style.visible = false

	table.insert(character_select, {
		value_id = "contracts_text",
		style_id = "contracts_text",
		pass_type = "text",
		value = "---",
		style = contracts_text_style,
		change_function = character_archetype_title_pass and character_archetype_title_pass.change_function
	})
end)

local _get_style_update = function()
	local corner = mod:get("corner")
	local left = corner == "tl" or corner == "bl"
	local top = corner == "tl" or corner == "tr"
	local align_h = left and "left" or "right"
	local align_v = top and "top" or "bottom"
	return {
		contracts_text = {
			text_horizontal_alignment = align_h,
			text_vertical_alignment = align_v,
			horizontal_alignment = align_h,
			vertical_alignment = align_v,
			visible = mod:is_enabled(),
			offset = {
				(left and 1 or -1) * (CONTRACTS_TEXT_OFFSET[1] + mod:get("offset_x")),
				(top and 1 or -1) * (CONTRACTS_TEXT_OFFSET[2] + mod:get("offset_y")),
				CONTRACTS_TEXT_OFFSET[3]
			}
		}
	}
end

return {
	get_style_update = _get_style_update
}
