local mod = get_mod("InventoryStats")

local UIWidget = require("scripts/managers/ui/ui_widget")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")

local invstat_title_font_style = table.clone(UIFontSettings.body)
invstat_title_font_style.offset = {
    -60,
    0,
    3
}
invstat_title_font_style.text_horizontal_alignment = "left"
invstat_title_font_style.text_vertical_alignment = "center"

local invstat_data_font_style = table.clone(invstat_title_font_style)
invstat_data_font_style.text_horizontal_alignment = "right"
invstat_data_font_style.text_vertical_alignment = "center"

mod:hook_require("scripts/ui/views/inventory_view/inventory_view_definitions", function(defs)
    defs.scenegraph_definition.invstat_entry = {
        vertical_alignment = "center",
        parent = "screen",
        horizontal_alignment = "right",
        size = {
            250,
            40
        },
        position = {
            -25,
            -350,
            2
        }
    }
    defs.invstat_entry_definition = UIWidget.create_definition({
        {
            value = "",
            value_id = "title",
            pass_type = "text",
            style = invstat_title_font_style
        },
        {
            value = "",
            value_id = "data",
            pass_type = "text",
            style = invstat_data_font_style
        },
    }, "invstat_entry")
    defs.animations.invstat_on_enter = table.clone(defs.animations.wallet_on_enter)
    defs.animations.invstat_on_exit = table.clone(defs.animations.wallet_on_exit)
end)
