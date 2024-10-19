local mod = get_mod("MissionBrief")

local CircumstanceTemplates = require("scripts/settings/circumstance/circumstance_templates")
local DangerSettings = require("scripts/settings/difficulty/danger_settings")
local DialogueSpeakerVoiceSettings = require("scripts/settings/dialogue/dialogue_speaker_voice_settings")
local Missions = require("scripts/settings/mission/mission_templates")
local MissionTypes = require("scripts/settings/mission/mission_types")
local MissionObjectiveTemplates = require("scripts/settings/mission_objective/mission_objective_templates")
local UIRenderer = require("scripts/managers/ui/ui_renderer")
local UIFonts = require("scripts/managers/ui/ui_fonts")

mod:io_dofile("MissionBrief/scripts/mods/MissionBrief/ViewDefinitions")

-- draw widgets as normal
mod:hook(CLASS.MissionIntroView, "draw", function(func, self, ...)
	self.super.draw(self, ...)
	func(self, ...)
end)

mod:hook_safe(CLASS.MissionIntroView, "on_enter", function(self)
	local widgets = self._widgets_by_name
	if widgets.display then
		widgets.display.visible = false -- hide leftover widget lol
	end
	self._pass_draw = true

	local mech = Managers.mechanism and Managers.mechanism._mechanism
	local mech_data = mech and mech._mechanism_data

	--[[ DBG
	if not mech_data or not mech_data.challenge then
		mech_data = {
			challenge = 5,
			level_name = "content/levels/transit/missions/mission_cm_habs",
			resistance = 4,
			circumstance_name = "toxic_gas_more_resistance_01",
			backend_mission_id = "123",
			mission_giver_vo_override = "sergeant_b",
			mission_name = "cm_habs",
			side_mission = "side_mission_tome",
		}
	end
	mod.DBG_mech_data = mech_data
	--]]

	if mech_data then
		local mission_id = mech_data.mission_name
		local zone_height = 0
		if mission_id then
			local mission = Missions[mission_id]
			local mission_type = MissionTypes[mission.mission_type]

			local mission_content = widgets.mission_info.content
			mission_content.icon = mission_type and mission_type.icon or mission_content.icon
			mission_content.mission_name = Utf8.upper(Localize(mission.mission_name))
			mission_content.mission_type = Localize(mission_type.name)

			local side_mission_id = mech_data.side_mission
			if side_mission_id and side_mission_id ~= "default" then
				mission_content.mission_type = mission_content.mission_type .. " | " .. Localize(MissionObjectiveTemplates.side_mission.objectives[side_mission_id].header)
			end

			local zone_content = widgets.zone_info.content
			zone_content.zone_coords = Localize(mission.coordinates)
			zone_content.zone_description = Localize(mission.mission_description)
			local text_style = self._definitions.widget_definitions.zone_info.style.zone_description
			zone_height = 75 + UIRenderer.text_height(Managers.ui:ui_constant_elements():ui_renderer(), zone_content.zone_description, text_style.font_type, text_style.font_size, { 500, 2000 }, UIFonts.get_font_options_by_style(text_style))
		end

		widgets.mb_right_background.style.fade.size = { nil, 150 + zone_height }

		local difficulty = mech_data.challenge
		if difficulty then
			local difficulty_widget = widgets.danger_info
			difficulty_widget.style.difficulty_icon.amount = difficulty
			difficulty_widget.content.difficulty_name = Localize(DangerSettings.by_index[difficulty].display_name)
		end

		local circumstance_id = mech_data.circumstance_name
		local circumstance_height = 0
		local circumstance_widget = widgets.circumstance_info
		circumstance_widget.visible = false
		if circumstance_id and circumstance_id ~= "default" then
			local circumstance_data = CircumstanceTemplates[circumstance_id]
			local circumstance_ui = circumstance_data and circumstance_data.ui
			if circumstance_ui then
				local circumstance_content = circumstance_widget.content
				circumstance_content.icon = circumstance_ui.icon
				circumstance_content.circumstance_name = Localize(circumstance_ui.display_name)
				circumstance_content.circumstance_description = Localize(circumstance_ui.description)
				circumstance_widget.visible = true

				local text_style = self._definitions.widget_definitions.circumstance_info.style.circumstance_description
				circumstance_height = 75 + UIRenderer.text_height(Managers.ui:ui_constant_elements():ui_renderer(), circumstance_content.circumstance_description, text_style.font_type, text_style.font_size, { 500, 2000 }, UIFonts.get_font_options_by_style(text_style))
			end
		end

		widgets.mb_left_background.style.fade.size = { nil, 215 + circumstance_height }

		local mission_giver_id = mech_data.mission_giver_vo_override
		if mission_giver_id and mission_giver_id ~= "none" then
			local speaker = DialogueSpeakerVoiceSettings[mission_giver_id]
			widgets.npc_card.content.name_text = Localize(speaker.full_name)
			widgets.npc_card.style.portrait.material_values.main_texture = speaker.icon or widgets.npc_card.style.portrait.material_values.main_texture
		end
	end
end)

mod.DBG_screen = function()
	local view_name = "mission_intro_view"
	local view = Managers.ui:view_instance(view_name)
	if view then
		Managers.ui:close_view(view_name)
	else
		Managers.ui:open_view(view_name)
	end
end
