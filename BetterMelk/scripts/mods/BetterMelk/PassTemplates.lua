local mod = get_mod("BetterMelk")

local ColorUtilities = require("scripts/utilities/ui/colors")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")

local CONTRACTS_TEXT_OFFSET = { 173, 40, 10 }

local contracts_text_style = table.clone(UIFontSettings.body_small)
contracts_text_style.text_horizontal_alignment = "left"
contracts_text_style.text_vertical_alignment = "bottom"
contracts_text_style.horizontal_alignment = "left"
contracts_text_style.vertical_alignment = "center"
contracts_text_style.size = { 150, 20 }
contracts_text_style.offset = CONTRACTS_TEXT_OFFSET
contracts_text_style.text_color = Color.terminal_text_body_sub_header(255, true)
contracts_text_style.default_color = Color.terminal_text_body_sub_header(255, true)
contracts_text_style.hover_color = Color.terminal_text_header(255, true)
contracts_text_style.visible = false

local _text_color_change = function(content, style)
    local math_max = math.max
    local hotspot = content.hotspot
    local default_color = hotspot.disabled and style.disabled_color or style.default_color
    local hover_color = style.hover_color
    local text_color = style.text_color
    local progress = math_max(math_max(hotspot.anim_focus_progress, hotspot.anim_select_progress), math_max(hotspot.anim_hover_progress, hotspot.anim_input_progress))

    ColorUtilities.color_lerp(default_color, hover_color, progress, text_color)
end

mod:hook_require("scripts/ui/pass_templates/character_select_pass_templates", function(CharacterSelectPassTemplates)
    table.insert(CharacterSelectPassTemplates.character_select, {
        value_id = "contracts_text",
        style_id = "contracts_text",
        pass_type = "text",
        value = "---",
        style = contracts_text_style,
        change_function = _text_color_change
    })
end)

local _get_style_update = function()
    return {
        contracts_text = {
            visible = mod:is_enabled() and mod:get("show_contracts"),
            offset = { CONTRACTS_TEXT_OFFSET[1] + mod:get("contracts_x"), CONTRACTS_TEXT_OFFSET[2], CONTRACTS_TEXT_OFFSET[3] }
        }
    }
end

return {
    get_style_update = _get_style_update
}
