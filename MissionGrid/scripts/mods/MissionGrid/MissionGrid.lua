local mod = get_mod("MissionGrid")

local slot_layout_dirty = false

local resizers = mod:persistent_table("resizers")
local overriden_settings

local mission_to_slot = {}
local fallback_slot

local overridable_setting = function(key)
	local over = overriden_settings and overriden_settings[key]
	if over == nil then
		return mod:get(key)
	end
	return over
end

local track_resize = function(key, size, scale)
	local r = resizers[key]
	if r then
		r.scale = scale
	else
		resizers[key] = {
			original = table.clone(size),
			current = size,
			scale = scale,
		}
	end
end

local scale_resize = function(scale)
	scale = scale or overridable_setting("icon_scale")
	for _, r in pairs(resizers) do
		local r_scale = r.scale and (1 + r.scale * (scale - 1)) or scale
		r.current[1] = r.original[1] * r_scale
		r.current[2] = r.original[2] * r_scale
	end
end

mod.override_settings = function(override)
	overriden_settings = override
	slot_layout_dirty = true
	scale_resize()
end

local move_single_slot = function(theme_slots, category)
	local slot = theme_slots[category] and theme_slots[category][1]
	if slot then
		slot.position = {
			overridable_setting(category .. "_x") * 10,
			overridable_setting(category .. "_y") * 10
		}
	end
end

local put_slots_in_grid = function(theme_slots)
	local start_x = overridable_setting("start_x") * 10
	local spacing_x = overridable_setting("spacing_x") * 10
	local start_y = overridable_setting("start_y") * 10
	local spacing_y = overridable_setting("spacing_y") * 10
	local max_columns = overridable_setting("max_columns")

	local column = 0
	local row = 0
	local small_slots = theme_slots.small
	if small_slots then
		for i = 1, #small_slots do
			local slot = small_slots[i]
			slot.category_priority = nil
			slot.position = {
				start_x + spacing_x * column,
				start_y + spacing_y * row
			}

			column = column + 1
			if column >= max_columns then
				column = 0
				row = row + 1
			end
		end
	end

	theme_slots.mg_maelstrom = {
		rotation = 0,
		zoom = 1,
		position = {
			overridable_setting("maelstrom_x") * 10,
			overridable_setting("maelstrom_y") * 10
		},
	}
	move_single_slot(theme_slots, "static")
	move_single_slot(theme_slots, "large")
end

mod.on_setting_changed = function(id)
	if id == "icon_scale" then
		scale_resize()
	else
		slot_layout_dirty = true
	end
end

mod:hook_require("scripts/ui/views/mission_board_view_pj/mission_board_view_themes", function(themes)
	for _, theme in pairs(themes) do
		put_slots_in_grid(theme.slots)
	end
end)

local sort_missions = function(view)
	local theme_slots = view:_get_ui_theme().slots
	if slot_layout_dirty then
		put_slots_in_grid(theme_slots)
	end

	-- if we've already sorted these, don't do it again
	local missions = view._filtered_missions
	local sort_is_dirty = false
	for id, m in pairs(missions) do
		if m.category ~= "maelstrom" and mission_to_slot[id] == nil then
			sort_is_dirty = true
			break
		end
	end
	if not sort_is_dirty then
		return
	end

	-- put them into an array for sorting
	local now_t = Managers.time:time("main")
	local missions_array = {}
	for _, m in pairs(missions) do
		if m.category ~= "maelstrom" then
			missions_array[#missions_array + 1] = m
		end

		-- show missions that haven't quite started yet (h/t Aussiemon)
		if m.start_game_time and now_t < m.start_game_time then
			m.start_game_time = now_t - 1
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

		local b_is_event = b.category == "event"
		if (a.category == "event") ~= b_is_event then
			-- put event missions last
			return b_is_event
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
	table.clear(mission_to_slot)

	local small_slots = theme_slots.small
	fallback_slot = small_slots[#small_slots]
	for i = 1, #missions_array do
		local id = missions_array[i].id
		local slot = small_slots[i]
		mission_to_slot[id] = slot
		local widget = widgets_by_name[id]
		if widget and slot then
			widget.offset[1] = slot.position[1]
			widget.offset[2] = slot.position[2]
		end
	end
end

mod:hook_require("scripts/ui/views/mission_board_view_pj/mission_board_view_blueprints", function(Blueprints)
	local small_def = Blueprints.small_mission_definition
	track_resize("base", small_def.size)

	local small_def_style = small_def.style
	local track_style_size = function(style_id, scale)
		track_resize(style_id, small_def_style[style_id].size, scale)
	end
	track_style_size("timer_background")
	track_style_size("timer_bar")
	track_style_size("circumstance_icon", 0.5)
	track_style_size("main_objective_frame", 0.25)
	track_style_size("main_objective_icon", 0.25)
	track_style_size("side_objective_background", 0.25)
	track_style_size("side_objective_frame", 0.25)
	track_style_size("side_objective_icon", 0.25)

	scale_resize()
end)

mod:hook(CLASS.MissionBoardView, "_create_mission_widget_from_mission",
	function(func, self, mission, blueprint_name, ...)
		if blueprint_name == "mission_tile" and mission.category ~= "maelstrom" then
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
