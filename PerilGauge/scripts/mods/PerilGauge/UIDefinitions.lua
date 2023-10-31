local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")

local area_size = { 200, 200 }
local center_offset = 125

local bar_size = { 200, 9 }
local bar_bracket_spacing = 2
local bar_color = table.clone(UIHudSettings.color_tint_main_1)

local name_text_style = table.clone(UIFontSettings.body_small)
name_text_style.offset = { 0, 0, 3 }
name_text_style.size = area_size
name_text_style.horizontal_alignment = "center"
name_text_style.vertical_alignment = "center"
name_text_style.text_horizontal_alignment = "left"
name_text_style.text_vertical_alignment = "top"
name_text_style.text_color = table.clone(UIHudSettings.color_tint_main_2)
name_text_style.drop_shadow = false

return {
    scenegraph_definition = {
        screen = UIWorkspaceSettings.screen,
        area = {
            vertical_alignment = "center",
            parent = "screen",
            horizontal_alignment = "center",
            size = area_size,
            position = { 0, center_offset, 0 }
        },
        gauge = {
            vertical_alignment = "top",
            parent = "area",
            horizontal_alignment = "center",
            size = area_size,
            position = { 0, 0, 1 }
        },
    },
    widget_definitions = {
        gauge = UIWidget.create_definition({
            {
                value_id = "name_text",
                style_id = "name_text",
                pass_type = "text",
                value = "",
                style = name_text_style
            },
            {
                value = "content/ui/materials/hud/stamina_gauge",
                style_id = "bracket",
                pass_type = "rotated_texture",
                style = {
                    vertical_alignment = "center",
                    horizontal_alignment = "center",
                    offset = { 0, 0, 5 },
                    size = { 200 + 2.0 * bar_bracket_spacing, 10 },
                    pivot = { 100 + bar_bracket_spacing, 5 },
                    angle = 0.0,
                    color = UIHudSettings.color_tint_main_2
                }
            },
            {
                value = "content/ui/materials/hud/stamina_full",
                style_id = "segment",
                pass_type = "rect",
                style = {
                    vertical_alignment = "top",
                    horizontal_alignment = "left",
                    offset = { 0, 0, 2 },
                    size = bar_size,
                    color = bar_color
                }
            }
        }, "gauge")
    },
    default_values = {
        bar_size = bar_size,
        bar_color = bar_color,
        bar_bracket_spacing = bar_bracket_spacing
    }
}
