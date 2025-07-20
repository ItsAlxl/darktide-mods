local mod = get_mod("StoryReplay")

mod:io_dofile("StoryReplay/scripts/mods/StoryReplay/ViewDefinitions")

local show_story_only = false

mod:hook_safe(CLASS.MissionBoardView, "on_enter", function(self, ...)
	local toggle_widget_content = self._widgets_by_name.sr_story_toggle.content

	toggle_widget_content.checked = show_story_only
	toggle_widget_content.hotspot.pressed_callback = function()
		show_story_only = not toggle_widget_content.checked
		toggle_widget_content.checked = show_story_only
		self:_open_current_page()
	end
end)

mod:hook_safe(CLASS.MissionBoardView, "_open_current_page", function(self, ...)
	if show_story_only then
		self:_remove_mission_widget(self._widgets_by_name.qp_mission_widget)
	end
end)

mod:hook(CLASS.MissionBoardViewLogic, "_should_show_mission", function(func, self, mission)
	if show_story_only then
		return mission.category == "story"
	end
	return func(self, mission)
end)

mod:hook(CLASS.MissionBoardViewLogic, "_remove_unwanted_missions", function(func, self, missions)
	if show_story_only then
		local story_order = self._ordered_story_missions
		local story_data = self:_get_missions_per_category("story")
		local max_story = -1

		for i = 1, #story_order do
			if not story_data[story_order[i].key].unlocked then
				max_story = i - 1
				break
			end
		end
		if max_story < 0 then
			max_story = #story_order
		end

		for mission_id, mission in pairs(missions) do
			if mission.category == "story" then
				local unlocked = false
				for i = 1, max_story do
					if mission.map == story_order[i].key then
						unlocked = true
						break
					end
				end
				if not unlocked then
					missions[mission_id] = nil
				end
			elseif mission.category == "common" then
				missions[mission_id] = nil
			end
		end
		self._filtered_missions = missions
	else
		func(self, missions)
	end
end)
