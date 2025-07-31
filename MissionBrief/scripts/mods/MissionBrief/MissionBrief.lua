local mod = get_mod("MissionBrief")

local CircumstanceTemplates = require("scripts/settings/circumstance/circumstance_templates")
local Danger = require("scripts/utilities/danger")
local DialogueSpeakerVoiceSettings = require("scripts/settings/dialogue/dialogue_speaker_voice_settings")
local Havoc = require("scripts/utilities/havoc")
local Missions = require("scripts/settings/mission/mission_templates")
local MissionTypes = require("scripts/settings/mission/mission_types")
local MissionObjectiveTemplates = require("scripts/settings/mission_objective/mission_objective_templates")
local UIRenderer = require("scripts/managers/ui/ui_renderer")
local UIFonts = require("scripts/managers/ui/ui_fonts")
local Zones = require("scripts/settings/zones/zones")

mod:io_dofile("MissionBrief/scripts/mods/MissionBrief/ViewDefinitions")

-- normally unnecessary (these packages are always loaded), but needed for Psych Ward
local force_packages = {
	{ path = "packages/ui/hud/mission_speaker_popup/mission_speaker_popup" },
	{ path = "packages/ui/hud/tactical_overlay/tactical_overlay" },
	{ path = "packages/ui/views/mission_board_view/mission_board_view" },
}

local _load_packages = function()
	for _, package in ipairs(force_packages) do
		package.id = package.id or Managers.package:load(package.path, mod.name, nil, true)
	end
end
_load_packages()

mod:hook_safe(CLASS.MissionIntroView, "draw", function(self, ...)
	self.super.draw(self, ...) -- draw widgets as normal
end)

local calc_text_height = function(renderer, style, text, size)
	return UIRenderer.text_height(
		renderer,
		text,
		style.font_type,
		style.font_size,
		size or { 500, 2000 },
		UIFonts.get_font_options_by_style(style)
	)
end

mod:hook_safe(CLASS.MissionIntroView, "on_enter", function(self)
	local widgets = self._widgets_by_name
	if widgets.display then
		widgets.display.visible = false -- hide leftover widget lol
	end
	self._pass_draw = true
	self:set_render_scale(mod:get("ui_scale") or 1.0)

	local mech_data = Managers.mechanism:mechanism_data()
	--[[ DBG
	mech_data = {
		challenge = 4,
		level_name = "content/levels/transit/missions/mission_cm_habs",
		resistance = 4,
		circumstance_name = "hunting_grounds_more_resistance_01",
		backend_mission_id = "123",
		mission_giver_vo_override = "sergeant_b",
		mission_name = "fm_resurgence",
		side_mission = "side_mission_tome",
		havoc_data = "km_heresy;31;darkness;cultist;mutator_encroaching_garden:mutator_highest_difficulty:mutator_havoc_chaos_rituals:darkness_hunting_grounds_01;26.4:1.5:4.4:13.5:7.5:11.4:10.4:8.4:9.4:6.5:12.5:22.4:23.5:5.4:3.4:2.4:25.4:24.4;5;5",
	}
	--]]
	local havoc_data = mech_data.havoc_data and Havoc.parse_data(mech_data.havoc_data)

	local show_mission = mod:get("show_mission")
	widgets.mb_left_background.visible = show_mission
	widgets.mission_info.visible = show_mission

	local show_fluff = mod:get("show_fluff")
	widgets.mb_right_background.visible = show_fluff
	widgets.zone_info.visible = show_fluff
	widgets.npc_card.visible = show_fluff

	if mech_data then
		local widget_defs = self._definitions.widget_definitions

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
				mission_content.mission_type = mission_content.mission_type .. " · " ..
					Localize(MissionObjectiveTemplates.side_mission.objectives[side_mission_id].header)
			end

			local zone_content = widgets.zone_info.content
			local zone = Zones[mission.zone_id or "operations"]
			zone_content.zone_coords = zone and Localize(zone.name) or ""
			zone_content.zone_description = mission.mission_description and Localize(mission.mission_description) or ""

			zone_height = calc_text_height(
				self._ui_renderer,
				widget_defs.zone_info.style.zone_description,
				zone_content.zone_description
			)
		end
		widgets.mb_right_background.style.fade.size = { nil, 225 + zone_height }

		local circumstance_height = 0
		local hrank_widget = widgets.havoc_rank_info
		local difficulty_widget = widgets.danger_info
		local circumstance_widget = widgets.circumstance_info
		local havoc_circumstance_info = widgets.havoc_circumstance_info
		circumstance_widget.visible = false
		havoc_circumstance_info.visible = false
		if havoc_data then
			hrank_widget.visible = show_mission
			difficulty_widget.visible = false

			hrank_widget.content.havoc_rank = Utf8.upper(Localize("loc_havoc_name") .. " " .. havoc_data.havoc_rank)

			local mutators = havoc_data.circumstances
			local num_displayed_mutators = 0
			for i = 1, #mutators do
				local mutator_data = mutators[i]
				num_displayed_mutators = num_displayed_mutators + 1

				local circumstance_info_content = havoc_circumstance_info.content
				local circumstance_info_style = havoc_circumstance_info.style
				local circumstance_ui_settings = CircumstanceTemplates[mutator_data].ui
				local circumstance_icon = circumstance_ui_settings.icon

				circumstance_info_content.icon = circumstance_icon
				local circumstance_icon_identifer = "icon_0" .. i
				circumstance_info_content[circumstance_icon_identifer] = circumstance_icon
				circumstance_info_style[circumstance_icon_identifer].offset[2] = circumstance_height

				local circumstance_name_identifer = "circumstance_name_0" .. i
				circumstance_info_content[circumstance_name_identifer] = Localize(circumstance_ui_settings.display_name)
				circumstance_info_style[circumstance_name_identifer].offset[2] = circumstance_height

				circumstance_height = circumstance_height + 40

				local description = Localize(circumstance_ui_settings.description)
				local circumstance_description_identifier = "circumstance_description_0" .. i
				circumstance_info_content[circumstance_description_identifier] = description
				circumstance_info_style[circumstance_description_identifier].offset[2] = circumstance_height

				circumstance_height = circumstance_height + calc_text_height(
					self._ui_renderer,
					widget_defs.havoc_circumstance_info.style[circumstance_description_identifier],
					description
				)

				havoc_circumstance_info.visible = show_mission
			end

			havoc_circumstance_info.num_displayed_mutators = num_displayed_mutators
			if num_displayed_mutators > 0 then
				circumstance_height = circumstance_height + 25
			end

			if num_displayed_mutators ~= 4 then
				for i = num_displayed_mutators + 1, 4 do
					local circumstance_icon_identifer = "icon_0" .. i
					local icon_style = havoc_circumstance_info.style[circumstance_icon_identifer]
					icon_style.visible = false

					local circumstance_name_identifer = "circumstance_name_0" .. i
					local name_style = havoc_circumstance_info.style[circumstance_name_identifer]
					name_style.visible = false

					local circumstance_description_identifier = "circumstance_description_0" .. i
					local description_style = havoc_circumstance_info.style[circumstance_description_identifier]
					description_style.visible = false
				end
			end
		else
			hrank_widget.visible = false
			difficulty_widget.visible = show_mission

			local difficulty = Danger.danger_by_difficulty(mech_data.challenge, mech_data.resistance)
			if difficulty then
				local widget_content = difficulty_widget.content
				widget_content.difficulty_icon = difficulty.icon or
					"content/ui/materials/icons/difficulty/flat/difficulty_skull_uprising"
				widget_content.difficulty_name = Localize(difficulty.display_name)

				local icon_style = difficulty_widget.style.difficulty_icon
				icon_style.amount = difficulty.index or 0
				icon_style.color = difficulty.color or { 255, 255, 255, 255 }
			end

			local circumstance_id = mech_data.circumstance_name
			if circumstance_id and circumstance_id ~= "default" then
				local circumstance_data = CircumstanceTemplates[circumstance_id]
				local circumstance_ui = circumstance_data and circumstance_data.ui
				if circumstance_ui then
					local circumstance_content = circumstance_widget.content
					circumstance_content.icon = circumstance_ui.icon
					circumstance_content.circumstance_name = Localize(circumstance_ui.display_name)
					circumstance_content.circumstance_description = Localize(circumstance_ui.description)
					circumstance_widget.visible = show_mission

					circumstance_height = circumstance_height + 75 + calc_text_height(
						self._ui_renderer,
						widget_defs.circumstance_info.style.circumstance_description,
						circumstance_content.circumstance_description
					)
				end
			end
		end

		widgets.mb_left_background.style.fade.size = { nil, 215 + circumstance_height }

		local mission_giver_id = mech_data.mission_giver_vo_override
		if mission_giver_id and mission_giver_id ~= "none" then
			local speaker = DialogueSpeakerVoiceSettings[mission_giver_id]
			local npc_card = widgets.npc_card
			npc_card.content.name_text = Localize(speaker.full_name)

			local portrait_material_vals = widgets.npc_card.style.portrait.material_values
			portrait_material_vals.main_texture = speaker.icon or portrait_material_vals.main_texture
		end
	end
end)

mod.on_setting_changed = function(id)
	if id == "panel_width" then
		mod.update_sizes(mod:get(id))
	end
	if id == "panel_alpha" then
		mod.update_bg_color(mod:get(id))
	end
end

mod.DBG_screen = function()
	local view_name = "mission_intro_view"
	local view = Managers.ui:view_instance(view_name)
	if view then
		Managers.ui:close_view(view_name)
	else
		Managers.ui:open_view(view_name)
	end
end
