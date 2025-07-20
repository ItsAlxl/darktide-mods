local mod = get_mod("StoryReplay")

local CheckboxPassTemplates = require("scripts/ui/pass_templates/checkbox_pass_templates")
local UIWidget = require("scripts/managers/ui/ui_widget")

mod:hook_require("scripts/ui/views/mission_board_view_pj/mission_board_view_definitions", function(view_defs)
	local scenegraph = view_defs.scenegraph_definition
	scenegraph.play_button.position[2] = 225
	scenegraph.difficulty_stepper.position[2] = -100

	scenegraph.sr_story_toggle = {
		horizontal_alignment = "center",
		parent = "difficulty_stepper",
		vertical_alignment = "top",
		size = {
			350,
			50
		},
		position = {
			0,
			-85,
			100,
		},
	}

	view_defs.widget_definitions.sr_story_toggle = UIWidget.create_definition(
		CheckboxPassTemplates.terminal_checkbox_button,
		"sr_story_toggle",
		{
			original_text = Localize("loc_player_journey_campaign"),
		}
	)
end)
