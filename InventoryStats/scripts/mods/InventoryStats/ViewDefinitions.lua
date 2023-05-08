local mod = get_mod("InventoryStats")

local ButtonPassTemplates = require("scripts/ui/pass_templates/button_pass_templates")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")

local invstat_title_font_style = table.clone(UIFontSettings.body)
invstat_title_font_style.offset = {
    0,
    0,
    -1
}
invstat_title_font_style.text_horizontal_alignment = "left"
invstat_title_font_style.text_vertical_alignment = "center"

local invstat_data_font_style = table.clone(invstat_title_font_style)
invstat_data_font_style.text_horizontal_alignment = "right"
invstat_data_font_style.text_vertical_alignment = "center"

local STAT_WIDTH = 300
local BG_PADDING = 10

mod:hook_require("scripts/ui/views/inventory_view/inventory_view_definitions", function(defs)
    defs.scenegraph_definition.invstat_entry = {
        vertical_alignment = "center",
        parent = "screen",
        horizontal_alignment = "right",
        size = {
            STAT_WIDTH,
            40
        },
        position = {
            -75,
            -360,
            2
        }
    }

    defs.visbtn_definition = UIWidget.create_definition(ButtonPassTemplates.terminal_button_small, "invstat_entry", {
        text = mod:localize("visbtn_text"),
    }, {
        STAT_WIDTH,
        40
    }) -- ButtonPassTemplates.tab_menu_button
    defs.pagenav_definition = UIWidget.create_definition(ButtonPassTemplates.terminal_button_small, "invstat_entry", {
        text = "-",
    }, {
        STAT_WIDTH * 0.5 - 5,
        30
    })

    defs.invstat_entry_definition = UIWidget.create_definition({
        {
            style_id = "bg",
            pass_type = "rect",
            style = {
                vertical_alignment = "bottom",
                horizontal_alignment = "left",
                offset = {
                    -BG_PADDING,
                    0,
                    -2
                },
                size = {
                    STAT_WIDTH + 2 * BG_PADDING,
                    40
                },
                color = {
                    128,
                    0,
                    0,
                    0
                }
            }
        },
        {
            value = "???",
            value_id = "title",
            pass_type = "text",
            style = invstat_title_font_style
        },
        {
            value = "---",
            value_id = "data",
            pass_type = "text",
            style = invstat_data_font_style
        },
    }, "invstat_entry")
end)
