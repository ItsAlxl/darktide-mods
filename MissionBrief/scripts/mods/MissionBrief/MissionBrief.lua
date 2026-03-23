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

local force_packages = {
	{ path = "packages/ui/hud/mission_speaker_popup/mission_speaker_popup" },
	{ path = "packages/ui/hud/tactical_overlay/tactical_overlay" },
	{ path = "packages/ui/views/mission_board_view/mission_board_view" },
	{ path = "packages/ui/views/expedition_play_view/expedition_play_view" },
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
		moved to a different package and I was too lazy to go searching
		for it; this'll work even if it moves again
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
		local max_num_modifiers = 4
		for i = 1, #mission_modifiers_data do
			local modifier_data = mission_modifiers_data[i]
			if modifier_data then
				num_displayed_modifiers = num_displayed_modifiers + 1

				local modifier_info_content = info_widget.content
				local modifier_info_style = info_widget.style

				local modifier_icon_id = "icon_0" .. num_displayed_modifiers
				modifier_info_content[modifier_icon_id] = modifier_data.icon
				modifier_info_style[modifier_icon_id].offset[2] = modifiers_height

				local modifier_name_id = "modifier_name_0" .. num_displayed_modifiers
				modifier_info_content[modifier_name_id] = modifier_data.name
				modifier_info_style[modifier_name_id].offset[2] = modifiers_height

				modifiers_height = modifiers_height + 40

				local description = modifier_data.description
				local modifier_description_identifier = "modifier_description_0" .. num_displayed_modifiers
				modifier_info_content[modifier_description_identifier] = description
				modifier_info_style[modifier_description_identifier].offset[2] = modifiers_height

				modifiers_height = modifiers_height + calc_text_height(
					view._ui_renderer,
					view._definitions.widget_definitions.modifiers_info.style[modifier_description_identifier],
					description
				)

				if num_displayed_modifiers >= max_num_modifiers then
					break
				end
			end
		end

		info_widget.visible = mod:get("show_mission") and num_displayed_modifiers > 0
		if num_displayed_modifiers > 0 then
			modifiers_height = modifiers_height + 25
		end

		for i = 1, max_num_modifiers do
			local visible = i <= num_displayed_modifiers
			info_widget.style["icon_0" .. i].visible = visible
			info_widget.style["modifier_name_0" .. i].visible = visible
			info_widget.style["modifier_description_0" .. i].visible = visible
		end
	end

	widgets.mb_left_background.style.fade.size = { nil, 215 + modifiers_height }
end

mod:hook_safe(CLASS.MissionIntroView, "on_enter", function(self)
	local widgets = self._widgets_by_name
	if widgets.display then
		widgets.display.visible = false -- hide leftover widget lol
	end
	self._pass_draw = true
	self:set_render_scale(mod:get("ui_scale") or 1.0)

	local mech_data = mod.mech_data_override or Managers.mechanism:mechanism_data()
	mod.mech_data_override = nil -- only used for debugging
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
		local mission_content = widgets.mission_info.content
		if mission_id then
			local mission = Missions[mission_id]
			local mission_type = MissionTypes[mission.mission_type]

			mission_content.icon = _sanitize_icon(mission_type and mission_type.icon or mission_content.icon)
			mission_content.mission_name = Utf8.upper(Localize(mission.mission_name))
			mission_content.mission_type = Localize(mission_type.name)

			local side_mission_id = mech_data.side_mission
			if side_mission_id and side_mission_id ~= "default" then
				mission_content.mission_type = mission_content.mission_type
					.. " · "
					.. Localize(MissionObjectiveTemplates.side_mission.objectives[side_mission_id].header)
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

		_update_modifiers_list(self, mission_modifiers)
		if mech_data.expedition_template_name and mech_data.node_id then
			Managers.data_service.expedition:fetch_nodes():next(function(node_data)
				local node = node_data.nodes_by_id[mech_data.node_id]
				if node then
					local node_missions = node.missions
					for i = 1, #node_missions do
						local mission = node_missions[i]
						if mission.id == mech_data.backend_mission_id then
							_update_modifiers_list(self, mission.modifiers)
							local node_name = node.ui and node.ui.display_name
							if node_name then
								mission_content.mission_type = Localize("loc_grid_point") .. " " .. Localize(node_name)
							end
							break
						end
					end
				end
			end):catch(function(error)
				mod:error(tostring(table.tostring(error, 1)))
			end)
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
