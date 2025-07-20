local mod = get_mod("MissionGrid")

local spacing_x = 200
local spacing_y = 200
local max_columns = 6
local num_slots = max_columns * 4

local mission_to_slot = {}
local fallback_slot

mod:hook_require("scripts/ui/views/mission_board_view_pj/mission_board_view_themes", function(themes)
	for _, theme in pairs(themes) do
		-- create some extra slots (in case we need, like, a lot of missions displayed at once)
		local small_slots = theme.slots.small
		for i = #small_slots, num_slots do
			small_slots[i + 1] = {}
		end

		-- arrange mission slots in a grid
		local column = 0
		local row = 0.2
		for i = 1, #small_slots do
			local slot = small_slots[i]
			slot.category_priority = nil
			slot.position = { spacing_x * column, spacing_y * row }
			column = column + 1
			if column >= max_columns then
				column = 0
				row = row + 1
			end
		end
		theme.slots.mg_maelstrom = {
			rotation = 0,
			zoom = 1,
			position = {
				975,
				525
			},
		}
	end
end)

local sort_missions = function(view)
	local missions = view._filtered_missions

	-- if we've already sorted these, don't do it again
	local sort_is_dirty = false
	for id, _ in pairs(missions) do
		if mission_to_slot[id] == nil then
			sort_is_dirty = true
			break
		end
	end
	if not sort_is_dirty then
		return
	end

	-- show missions that haven't quite started yet (h/t Aussiemon)
	local t = Managers.time:time("main")
	for i = 1, #missions do
		if missions[i] and t < missions[i].start_game_time then
			missions[i].start_game_time = t - 1
		end
	end

	-- put them into an array for sorting
	local missions_array = {}
	for _, m in pairs(missions) do
		if m.category ~= "maelstrom" then
			missions_array[#missions_array + 1] = m
		end
	end

	local mb_logic = view._mission_board_logic
	local mb_campaign_order = mb_logic.get_campaign_mission_display_order
	table.sort(missions_array, function(a, b)
		local a_is_story = a.category == "story"
		if a_is_story ~= (b.category == "story") then
			-- if only one of a or b is a story mission, the story mission goes first
			return a_is_story
		elseif a_is_story then
			-- if they're both story missions, put them in story order
			return mb_campaign_order(mb_logic, a.map, a.category) < mb_campaign_order(mb_logic, b.map, b.category)
		end

		-- group modifiers together; no modifier goes first
		if a.circumstance ~= b.circumstance then
			return a.circumstance == "default" or (b.circumstance ~= "default" and a.circumstance < b.circumstance)
		end

		-- group side missions (books)
		local a_side = a.side_mission or ""
		local b_side = b.side_mission or ""
		if a_side ~= b_side then
			return a_side < b_side
		end

		-- otherwise idc
		return a.map < b.map
	end)

	-- assign missions to slots, move widgets if they already exist
	local widgets_by_name = view._widgets_by_name
	local slots = view:_get_ui_theme().slots.small
	table.clear(mission_to_slot)

	for i = 1, #missions_array do
		local id = missions_array[i].id
		local slot = slots[i]
		mission_to_slot[id] = slot
		local widget = widgets_by_name[id]
		if widget and slot then
			widget.offset[1] = slot.position[1]
			widget.offset[2] = slot.position[2]
		end
	end
	fallback_slot = slots[#slots]
end

mod:hook(CLASS.MissionBoardView, "_create_mission_widget_from_mission",
	function(func, self, mission, blueprint_name, ...)
		if blueprint_name == "small_mission_definition" and mission.category ~= "maelstrom" then
			return func(self, mission, blueprint_name, mission_to_slot[mission.id] or fallback_slot)
		end
		return func(self, mission, blueprint_name, ...)
	end
)

mod:hook(CLASS.MissionBoardView, "_replace_mission_widget", function(func, self, ...)
	sort_missions(self)
	return func(self, ...)
end)

mod:hook(CLASS.MissionBoardView, "_add_mission_widget", function(func, self, ...)
	sort_missions(self)
	func(self, ...)
end)

mod:hook(CLASS.MissionBoardView, "_remove_mission_widget", function(func, self, ...)
	sort_missions(self)
	func(self, ...)
end)

mod:hook(CLASS.MissionBoardView, "_claim_slot", function(func, self, slot_group, mission_category)
	if mission_category == "maelstrom" then
		return self:_get_ui_theme().slots.mg_maelstrom
	end
	return func(self, slot_group, mission_category)
end)

mod:hook(CLASS.MissionBoardView, "_release_slot", function(func, self, slot)
	if slot.group and slot.group ~= "small" then
		func(self, slot)
	else
		self._used_slots.small = nil
	end
end)
