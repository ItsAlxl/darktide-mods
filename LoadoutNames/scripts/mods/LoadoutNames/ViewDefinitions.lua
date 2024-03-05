local mod = get_mod("LoadoutNames")

local TextInputPassTemplates = require("scripts/ui/pass_templates/text_input_pass_templates")
local UIWidget = require("scripts/managers/ui/ui_widget")

local tbox_definition = table.clone(TextInputPassTemplates.simple_input_field)

mod:hook_require("scripts/ui/view_elements/view_element_profile_presets/view_element_profile_presets_definitions", function(defs)
    defs.scenegraph_definition.loadout_name = {
        vertical_alignment = "center",
        parent = "screen",
        horizontal_alignment = "right",
        size = {
            300,
            40
        },
        position = {
            -75,
            -360,
            50
        }
    }

    defs.widget_definitions.loadout_tbox = UIWidget.create_definition(tbox_definition, "loadout_name", {
        placeholder_text = mod:localize("name_placeholder"),
    })
end)
