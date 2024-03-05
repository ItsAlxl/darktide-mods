local mod = get_mod("LoadoutNames")

local TextInputPassTemplates = require("scripts/ui/pass_templates/text_input_pass_templates")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")

local tbox_definition = table.clone(TextInputPassTemplates.simple_input_field)

local tooltip_text_style = table.clone(UIFontSettings.body)
tooltip_text_style.text_horizontal_alignment = "center"
tooltip_text_style.text_vertical_alignment = "center"
tooltip_text_style.horizontal_alignment = "center"
tooltip_text_style.vertical_alignment = "center"
tooltip_text_style.color = Color.white(255, true)
tooltip_text_style.offset = {
    0,
    0,
    2
}

mod:hook_require("scripts/ui/view_elements/view_element_profile_presets/view_element_profile_presets_definitions", function(defs)
    defs.scenegraph_definition.loadout_name_tbox_area = {
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
            0
        }
    }
    defs.widget_definitions.loadout_name_tbox = UIWidget.create_definition(tbox_definition, "loadout_name_tbox_area", {
        placeholder_text = mod:localize("name_placeholder"),
    })

    defs.scenegraph_definition.loadout_name_tooltip_area = {
        vertical_alignment = "top",
        parent = "screen",
        horizontal_alignment = "right",
        size = {
            350,
            40
        },
        position = {
            -75,
            50,
            0
        }
    }
    defs.widget_definitions.loadout_name_tooltip = UIWidget.create_definition({
		{
			pass_type = "rect",
			style = {
				vertical_alignment = "center",
				horizontal_alignment = "center",
				offset = {
					0,
					0,
					1
				},
				color = Color.black(128+64, true),
				size_addition = {
					0,
					10
				}
			}
		},
		{
			value_id = "text",
			style_id = "text",
			pass_type = "text",
			value = "Loadout Name",
			style = tooltip_text_style
		}
	}, "loadout_name_tooltip_area")
end)
