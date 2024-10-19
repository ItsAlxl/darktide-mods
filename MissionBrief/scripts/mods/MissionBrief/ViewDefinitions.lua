local mod = get_mod("MissionBrief")

local HudElementMissionSpeakerPopupSettings = require("scripts/ui/hud/elements/mission_speaker_popup/hud_element_mission_speaker_popup_settings")
local TacOverlaySettings = require("scripts/ui/hud/elements/tactical_overlay/hud_element_tactical_overlay_settings")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")

mod:hook_require("scripts/ui/views/mission_intro_view/mission_intro_view_definitions", function(view_defs)
	view_defs.scenegraph_definition.screen = UIWorkspaceSettings.screen
	view_defs.scenegraph_definition.left_panel = {
		parent = "screen",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = {
			600,
			400
		},
		position = {
			0,
			50,
			0,
		},
	}
	view_defs.scenegraph_definition.mission_info_panel = {
		parent = "left_panel",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size =
		{
			500,
			150
		},
		position = {
			25,
			-25,
			1,
		},
	}
	view_defs.scenegraph_definition.difficulty_panel = {
		parent = "left_panel",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size =
		{
			500,
			100
		},
		position = {
			25,
			135,
			1,
		},
	}
	view_defs.scenegraph_definition.circumstance_info_panel = {
		parent = "left_panel",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = {
			500,
			120
		},
		position = {
			25,
			215,
			1,
		},
	}
	view_defs.scenegraph_definition.right_panel = {
		parent = "screen",
		horizontal_alignment = "right",
		vertical_alignment = "top",
		size = {
			600,
			400
		},
		position = {
			0,
			50,
			0,
		},
	}
	view_defs.scenegraph_definition.npc_info_panel = {
		parent = "right_panel",
		horizontal_alignment = "right",
		vertical_alignment = "top",
		size =
		{
			500,
			150
		},
		position = {
			-25,
			0,
			1,
		},
	}
	view_defs.scenegraph_definition.zone_info_panel = {
		parent = "right_panel",
		horizontal_alignment = "right",
		vertical_alignment = "top",
		size =
		{
			500,
			150
		},
		position = {
			-25,
			150,
			1,
		},
	}

	view_defs.widget_definitions.mb_left_background = UIWidget.create_definition({
		{
			pass_type = "texture_uv",
			style_id = "fade",
			value = "content/ui/materials/hud/backgrounds/fade_horizontal",
			style = {
				color = Color.black(200, true),
				offset = {
					0,
					0,
					-3,
				},
				uvs = {
					{
						0,
						0,
					},
					{
						1,
						1,
					},
				},
			},
		}
	}, "left_panel")
	view_defs.widget_definitions.danger_info = UIWidget.create_definition({
		{
			pass_type = "text",
			value_id = "difficulty_name",
			style = {
				horizontal_alignment = "center",
				text_horizontal_alignment = "left",
				text_vertical_alignment = "top",
				vertical_alignment = "bottom",
				offset = {
					15,
					-25,
					10,
				},
				text_color = {
					255,
					169,
					191,
					153,
				},
			},
		},
		{
			pass_type = "texture",
			value = "content/ui/materials/icons/generic/danger",
			style = {
				horizontal_alignment = "left",
				vertical_alignment = "top",
				color = {
					255,
					169,
					191,
					153,
				},
				offset = {
					5,
					5,
					2,
				},
				size = {
					50,
					50,
				},
			},
		},
		{
			pass_type = "multi_texture",
			style_id = "diffulty_icon_background",
			value = "content/ui/materials/backgrounds/default_square",
		},
		{
			pass_type = "multi_texture",
			style_id = "diffulty_icon_background_frame",
			value = "content/ui/materials/frames/frame_tile_2px",
		},
		{
			pass_type = "multi_texture",
			style_id = "difficulty_icon",
			value = "content/ui/materials/backgrounds/default_square",
		},
	}, "difficulty_panel", nil, nil, TacOverlaySettings.styles.difficulty)

	view_defs.widget_definitions.mission_info = UIWidget.create_definition({
		{
			pass_type = "texture",
			value = "content/ui/materials/icons/generic/danger",
			value_id = "icon",
			style = {
				horizontal_alignment = "left",
				vertical_alignment = "center",
				color = Color.terminal_text_header(255, true),
				offset = {
					0,
					10,
					2,
				},
				size = {
					60,
					60,
				},
			},
		},
		{
			pass_type = "text",
			style_id = "mission_name",
			value_id = "mission_name",
			style = {
				font_size = 34,
				horizontal_alignment = "left",
				text_horizontal_alignment = "left",
				text_vertical_alignment = "top",
				vertical_alignment = "center",
				offset = {
					75,
					0,
					10,
				},
				size = {
					nil,
					50,
				},
				text_color = {
					255,
					169,
					191,
					153,
				},
			},
		},
		{
			pass_type = "text",
			style_id = "mission_type",
			value_id = "mission_type",
			style = {
				horizontal_alignment = "center",
				text_horizontal_alignment = "left",
				text_vertical_alignment = "top",
				vertical_alignment = "bottom",
				offset = {
					75,
					0,
					10,
				},
				size = {
					nil,
					60,
				},
				text_color = {
					255,
					169,
					191,
					153,
				},
			},
		},
	}, "mission_info_panel")
	view_defs.widget_definitions.circumstance_info = UIWidget.create_definition({
		{
			pass_type = "texture",
			style_id = "icon",
			value = "content/ui/materials/icons/generic/danger",
			value_id = "icon",
			style = {
				horizontal_alignment = "left",
				vertical_alignment = "top",
				color = Color.golden_rod(255, true),
				offset = {
					10,
					0,
					2,
				},
				size = {
					40,
					40,
				},
			},
		},
		{
			pass_type = "text",
			style_id = "circumstance_name",
			value_id = "circumstance_name",
			style = {
				horizontal_alignment = "left",
				text_horizontal_alignment = "left",
				text_vertical_alignment = "center",
				vertical_alignment = "top",
				offset = {
					60,
					0,
					10,
				},
				size = {
					nil,
					40,
				},
				text_color = Color.golden_rod(255, true),
			},
		},
		{
			pass_type = "text",
			style_id = "circumstance_description",
			value_id = "circumstance_description",
			style = {
				horizontal_alignment = "left",
				text_horizontal_alignment = "left",
				text_vertical_alignment = "top",
				vertical_alignment = "top",
				offset = {
					10,
					50,
					10,
				},
				size = {
					500,
					60,
				},
				text_color = {
					255,
					169,
					191,
					153,
				},
			},
		},
	}, "circumstance_info_panel")

	view_defs.widget_definitions.mb_right_background = UIWidget.create_definition({
		{
			pass_type = "texture_uv",
			style_id = "fade",
			value = "content/ui/materials/hud/backgrounds/fade_horizontal",
			style = {
				color = Color.black(200, true),
				offset = {
					0,
					0,
					-3,
				},
				uvs = {
					{
						1,
						1,
					},
					{
						0,
						0,
					},
				},
			},
		}
	}, "right_panel")


	local portrait_size = HudElementMissionSpeakerPopupSettings.portrait_size
	local name_text_style = table.clone(UIFontSettings.hud_body)
	name_text_style.horizontal_alignment = "right"
	name_text_style.vertical_alignment = "top"
	name_text_style.text_horizontal_alignment = "right"
	name_text_style.text_vertical_alignment = "bottom"
	name_text_style.size = {
		650,
		40,
	}
	name_text_style.offset = {
		-(portrait_size[1] + 20),
		50,
		2,
	}
	name_text_style.drop_shadow = true
	name_text_style.font_size = 24

	view_defs.widget_definitions.npc_card = UIWidget.create_definition({
		{
			pass_type = "texture",
			style_id = "portrait",
			value = "content/ui/materials/base/ui_radio_portrait_base",
			style = {
				horizontal_alignment = "right",
				vertical_alignment = "center",
				offset = {
					-1,
					0,
					0,
				},
				color = {
					255,
					255,
					255,
					255,
				},
				material_values = {
					distortion = 0,
					main_texture = "content/ui/textures/icons/npc_portraits/mission_givers/default",
				},
				size = portrait_size,
			},
		},
		{
			pass_type = "texture",
			style_id = "frame",
			value = "content/ui/materials/hud/backgrounds/weapon_frame",
			style = {
				horizontal_alignment = "right",
				vertical_alignment = "center",
				color = Color.terminal_text_body_sub_header(255, true),
				offset = {
					0,
					0,
					2,
				},
				size = portrait_size,
				size_addition = {
					8,
					5,
				},
			},
		},
		{
			pass_type = "text",
			value_id = "name_text",
			value = "NPC Name",
			style = name_text_style,
		}
	}, "npc_info_panel")
	view_defs.widget_definitions.zone_info = UIWidget.create_definition({
		{
			pass_type = "text",
			value_id = "zone_coords",
			style = {
				horizontal_alignment = "right",
				text_horizontal_alignment = "right",
				text_vertical_alignment = "top",
				vertical_alignment = "top",
				offset = {
					0,
					0,
					10,
				},
				text_color = Color.golden_rod(255, true),
			},
		},
		{
			pass_type = "text",
			style_id = "zone_description",
			value_id = "zone_description",
			style = {
				horizontal_alignment = "right",
				text_horizontal_alignment = "right",
				text_vertical_alignment = "top",
				vertical_alignment = "top",
				offset = {
					0,
					50,
					10,
				},
				text_color = {
					255,
					169,
					191,
					153,
				},
			},
		},
	}, "zone_info_panel")
end)
