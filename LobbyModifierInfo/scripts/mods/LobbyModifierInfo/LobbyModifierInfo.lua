local mod = get_mod("LobbyModifierInfo")

local CircumstanceTemplates = require("scripts/settings/circumstance/circumstance_templates")
local ExpeditionMissionFlags = require("scripts/settings/expeditions/expedition_mission_flags")
local MutatorTemplates = require("scripts/settings/mutator/mutator_templates")

local force_packages = {
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
					icon = modifier_ui_data.icon,
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

		local widgets = view._widgets_by_name
		local margin = 20
		local offset = margin * 2

		local num_displayed_modifiers = 0
		local max_num_modifiers = 4
		for i = 1, #mission_modifiers_data do
			local modifier_data = mission_modifiers_data[i]
			if modifier_data then
				num_displayed_modifiers = num_displayed_modifiers + 1
				local widget = widgets["havoc_circumstance_0" .. num_displayed_modifiers]
				local widget_content = widget.content
				local widget_style = widget.style

				widget_content.icon = modifier_data.icon
				widget_content.circumstance_name = modifier_data.name
				widget_content.circumstance_description = modifier_data.description
				widget.offset[2] = offset

				local icon_height = widget_style.icon.size[2]
				local title_height = view:_get_text_height(
					widget_content.circumstance_name,
					widget_style.circumstance_name,
					{ widget_style.circumstance_name.size[1] }
				)
				title_height = math.max(icon_height, title_height)

				local description_height = view:_get_text_height(
					widget_content.circumstance_description,
					widget_style.circumstance_description,
					{ widget_style.circumstance_description.size[1] }
				)

				widget_style.circumstance_description.offset[2] = title_height

				local total_size = title_height + description_height
				widget.content.size = { nil, total_size }
				offset = offset + total_size + margin

				if num_displayed_modifiers >= max_num_modifiers then
					break
				end
			end
		end

		for i = 1, max_num_modifiers do
			widgets["havoc_circumstance_0" .. i].visible = i <= num_displayed_modifiers
		end
		widgets.havoc_title.visible = max_num_modifiers > 0
	end
end

mod:hook_safe(CLASS.LobbyView, "_setup_havoc_info", function(self)
	local havoc_title_style = self._widgets_by_name.havoc_title.style
	if self._havoc_data then
		havoc_title_style.havoc_icon.visible = true
		havoc_title_style.havoc_icon_drop_shadow.visible = true
		havoc_title_style.havoc_rank.visible = true
	else
		havoc_title_style.havoc_icon.visible = false
		havoc_title_style.havoc_icon_drop_shadow.visible = false
		havoc_title_style.havoc_rank.visible = false

		local mech_data = mod.mech_data_override or Managers.mechanism:mechanism_data()
		mod.mech_data_override = nil -- only used for debugging

		local mission_modifiers = nil
		local circumstance_id = mech_data.circumstance_name
		if circumstance_id and circumstance_id ~= "default" then
			mission_modifiers = { circumstance_id }
			local circumstance_data = CircumstanceTemplates[circumstance_id]
			local mutators = circumstance_data and circumstance_data.mutators
			for i = 1, #mutators do
				mission_modifiers[#mission_modifiers + 1] = mutators[i]
			end
		end

		_update_modifiers_list(self, mission_modifiers)
		if mech_data.expedition_template_name and mech_data.node_id then
			Managers.data_service.expedition:fetch_nodes():next(function(node_data)
				local expedition_node = node_data.nodes_by_id[mech_data.node_id]
				if expedition_node then
					local node_missions = expedition_node.missions
					for i = 1, #node_missions do
						local mission = node_missions[i]
						if mission.id == mech_data.backend_mission_id then
							local widgets = self._widgets_by_name
							_update_modifiers_list(self, mission.modifiers)
							local node_name = expedition_node.ui and expedition_node.ui.display_name
							if node_name then
								widgets.mission_title.content.sub_title = Localize("loc_grid_point")
									.. " " .. Localize(node_name)
							end
							break
						end
					end
				end
			end):catch(function(error)
				mod:error(tostring(table.tostring(error, 1)))
			end)
		end
	end
end)
