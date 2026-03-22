local mod = get_mod("MissionBrief")

local CircumstanceTemplates = require("scripts/settings/circumstance/circumstance_templates")
local Danger = require("scripts/utilities/danger")
local DialogueSpeakerVoiceSettings = require("scripts/settings/dialogue/dialogue_speaker_voice_settings")
local ExpeditionMissionFlags = require("scripts/settings/expeditions/expedition_mission_flags")
local Havoc = require("scripts/utilities/havoc")
local Missions = require("scripts/settings/mission/mission_templates")
local MissionTypes = require("scripts/settings/mission/mission_types")
local MissionObjectiveTemplates = require("scripts/settings/mission_objective/mission_objective_templates")
local MutatorTemplates = require("scripts/settings/mutator/mutator_templates")
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

local _sanitize_icon = function(icon)
	--[[
		'content/ui/materials/icons/mission_types_pj/mission_type_event'
		moved and I was too lazy to go searching for it; this'll work
		even if it moves again
	]]
	return (icon == "content/ui/materials/icons/mission_types_pj/mission_type_event"
			or icon == "content/ui/materials/icons/mission_types/mission_type_event")
		and "content/ui/materials/icons/mission_types/mission_type_side"
		or icon
end

local _get_modifier_ui_data = function(id)
	local ui_info = MutatorTemplates[id] and MutatorTemplates[id].ui
	if ui_info and ui_info.icon and ui_info.display_name and ui_info.description then
		return ui_info
	end

	ui_info = CircumstanceTemplates[id] and CircumstanceTemplates[id].ui
	if ui_info and ui_info.icon and ui_info.display_name and ui_info.description then
		return ui_info
	end

	return nil
end

local _get_modifier_flag_desc = function(id)
	local expedition_flag = ExpeditionMissionFlags[id]
	return expedition_flag and expedition_flag.ui and expedition_flag.ui.display_string
end

local _extract_and_validate_node_id = function(mission_flags)
	if not mission_flags then
		return nil
	end

	local node_id = nil
	local prefix = "exped-node-"
	for flag, _ in pairs(mission_flags) do
		local a, b = string.find(flag, prefix, 1, true)

		if a == 1 and b == #prefix then
			if node_id then
				return nil
			end
			node_id = string.sub(flag, #prefix + 1)
		end
	end
	return node_id
end

local _update_modifiers_list = function(view, mission_modifiers)
	local widgets = view._widgets_by_name
	local info_widget = widgets.modifiers_info

	local modifiers_height = 0
	info_widget.visible = false
	if mission_modifiers then
		local seen_modifiers = {}
		local mission_modifiers_data = {}
		local seen_flag_descriptions = {}
		local flag_aggregate_description = ""

		for i = 1, #mission_modifiers do
			local modifier_id = mission_modifiers[i]
			local modifier_ui_data = modifier_id ~= "default"
				and not seen_modifiers[modifier_id]
				and _get_modifier_ui_data(modifier_id) or nil

			if modifier_ui_data then
				seen_modifiers[modifier_id] = true
				mission_modifiers_data[#mission_modifiers_data + 1] = {
					icon = _sanitize_icon(modifier_ui_data.icon),
					name = Localize(modifier_ui_data.display_name),
					description = Localize(modifier_ui_data.description),
				}
			else
				local flag_desc = _get_modifier_flag_desc(modifier_id)
				if flag_desc and not seen_flag_descriptions[flag_desc] then
					seen_flag_descriptions[flag_desc] = true
					flag_aggregate_description = flag_aggregate_description
						.. (flag_aggregate_description == "" and "" or "\n\n")
						.. Localize(flag_desc)
				end
			end
		end

		if flag_aggregate_description ~= "" then
			mission_modifiers_data[#mission_modifiers_data + 1] = {
				icon = "content/ui/materials/icons/circumstances/placeholder",
				name = Localize("loc_glossary_term_circumstance_hazard"),
				description = flag_aggregate_description
			}
		end

		local num_displayed_modifiers = 0
		for i = 1, #mission_modifiers_data do
			local modifier_data = mission_modifiers_data[i]
			if modifier_data then
				num_displayed_modifiers = num_displayed_modifiers + 1

				local modifier_info_content = info_widget.content
				local modifier_info_style = info_widget.style

				local modifier_icon = modifier_data.icon
				modifier_info_content.icon = modifier_icon
				local modifier_icon_id = "icon_0" .. i
				modifier_info_content[modifier_icon_id] = modifier_icon
				modifier_info_style[modifier_icon_id].offset[2] = modifiers_height

				local modifier_name_id = "modifier_name_0" .. i
				modifier_info_content[modifier_name_id] = modifier_data.name
				modifier_info_style[modifier_name_id].offset[2] = modifiers_height

				modifiers_height = modifiers_height + 40

				local description = modifier_data.description
				local modifier_description_identifier = "modifier_description_0" .. i
				modifier_info_content[modifier_description_identifier] = description
				modifier_info_style[modifier_description_identifier].offset[2] = modifiers_height

				modifiers_height = modifiers_height + calc_text_height(
					view._ui_renderer,
					view._definitions.widget_definitions.modifiers_info.style[modifier_description_identifier],
					description
				)
			end
		end

		info_widget.visible = mod:get("show_mission") and num_displayed_modifiers > 0
		info_widget.num_displayed_modifiers = num_displayed_modifiers
		if num_displayed_modifiers > 0 then
			modifiers_height = modifiers_height + 25
		end

		if num_displayed_modifiers ~= 4 then
			for i = num_displayed_modifiers + 1, 4 do
				local modifier_icon_identifer = "icon_0" .. i
				local icon_style = info_widget.style[modifier_icon_identifer]
				icon_style.visible = false

				local modifier_name_identifer = "modifier_name_0" .. i
				local name_style = info_widget.style[modifier_name_identifer]
				name_style.visible = false

				local modifier_description_identifier = "modifier_description_0" .. i
				local description_style = info_widget.style[modifier_description_identifier]
				description_style.visible = false
			end
		end
	end

	widgets.mb_left_background.style.fade.size = { nil, 215 + modifiers_height }
end

local DBG_mech_data_override = nil

mod.DBG_screen = function(type)
	local view_name = "mission_intro_view"
	local view = Managers.ui:view_instance(view_name)
	if view then
		Managers.ui:close_view(view_name)
	else
		local type_id = type and string.sub(type, 1, 1) or "def"
		if type_id == "e" then
			DBG_mech_data_override = {
				challenge = 4,
				level_name = "content/levels/expeditions/start/world",
				resistance = 4,
				circumstance_name = "exps_dark",
				backend_mission_id = "missionbrief_dbg_" .. type,
				mission_giver_vo_override = "tech_priest_a",
				mission_name = "exp_wastes",
				side_mission = "default",
				expedition_template_name = "wastes"
			}

			Managers.data_service.expedition:fetch_expedition_missions():next(function(expeditions_data)
				local highest_modifiers = -1
				mod.DBG_fetched_expeds = expeditions_data
				for _, mission in ipairs(expeditions_data) do
					if mission.modifiers then
						local num_modifiers = #mission.modifiers
						if num_modifiers > highest_modifiers then
							highest_modifiers = num_modifiers
							DBG_mech_data_override.node_id = _extract_and_validate_node_id(mission.flags)
						end
					end
				end
				Managers.ui:open_view(view_name)
			end):catch(function(error)
				mod:error(error)
				Managers.ui:open_view(view_name)
			end)
		else
			DBG_mech_data_override = {
				challenge = 4,
				level_name = "content/levels/transit/missions/mission_cm_habs",
				resistance = 4,
				circumstance_name = "darkness_hunting_grounds_01",
				backend_mission_id = "missionbrief_dbg_" .. type_id,
				mission_giver_vo_override = "sergeant_b",
				mission_name = "fm_resurgence",
				side_mission = "side_mission_tome",
				havoc_data = type_id == "h"
					and
					"km_heresy;31;darkness;cultist;mutator_encroaching_garden:mutator_highest_difficulty:mutator_havoc_chaos_rituals:darkness_hunting_grounds_01;26.4:1.5:4.4:13.5:7.5:11.4:10.4:8.4:9.4:6.5:12.5:22.4:23.5:5.4:3.4:2.4:25.4:24.4;5;5"
					or nil
			}
			Managers.ui:open_view(view_name)
		end
	end
end

mod:hook_safe(CLASS.MissionIntroView, "on_enter", function(self)
	local widgets = self._widgets_by_name
	if widgets.display then
		widgets.display.visible = false -- hide leftover widget lol
	end
	self._pass_draw = true
	self:set_render_scale(mod:get("ui_scale") or 1.0)

	local mech_data = DBG_mech_data_override or Managers.mechanism:mechanism_data()
	local havoc_data = mech_data.havoc_data and Havoc.parse_data(mech_data.havoc_data)
	DBG_mech_data_override = nil
	mod.DBG_data = { mech = mech_data, havoc = havoc_data }

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
			mission_content.icon = _sanitize_icon(mission_type and mission_type.icon or mission_content.icon)
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

		local hrank_widget = widgets.havoc_rank_info
		local difficulty_widget = widgets.danger_info
		local mission_modifiers = nil
		if havoc_data then
			hrank_widget.visible = show_mission
			difficulty_widget.visible = false

			hrank_widget.content.havoc_rank = Utf8.upper(Localize("loc_havoc_name") .. " " .. havoc_data.havoc_rank)
			mission_modifiers = havoc_data.circumstances
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
				mission_modifiers = { circumstance_id }
				local circumstance_data = CircumstanceTemplates[circumstance_id]
				local mutators = circumstance_data and circumstance_data.mutators
				for i = 1, #mutators do
					mission_modifiers[#mission_modifiers + 1] = mutators[i]
				end
			end
		end

		if mech_data.expedition_template_name and mech_data.node_id then
			Managers.data_service.expedition:fetch_expedition_missions():next(function(expeditions_data)
				local found = false
				for _, mission in ipairs(expeditions_data) do
					local node_id = _extract_and_validate_node_id(mission.flags)
					if node_id and node_id == mech_data.node_id then
						_update_modifiers_list(self, mission.modifiers)
						found = true
						break
					end
				end
				if not found then
					_update_modifiers_list(self, mission_modifiers)
				end
			end):catch(function(error)
				mod:error(error)
				_update_modifiers_list(self, mission_modifiers)
			end)
		else
			_update_modifiers_list(self, mission_modifiers)
		end

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
