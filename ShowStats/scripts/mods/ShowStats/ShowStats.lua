local mod = get_mod("ShowStats")

mod:hook(CLASS.ViewElementPlayerStats, "init", function(func, self, ...)
	func(self, ...)
	self._max_active = math.huge
end)

mod:hook(CLASS.ViewElementPlayerStats, "_generate_shortcut_keys", function(func, self, ...)
	func(self, ...)
	if mod:get("auto_show") then
		self:_toggle_stats(true)
	end
end)

mod:hook(CLASS.InventoryBackgroundView, "_switch_active_view", function(func, self, view_name, ...)
	local stats = self._player_stats
	if stats and mod:get("auto_hide_talents") then
		if view_name == "talent_builder_view" and mod:get("auto_hide_talents") then
			stats:_toggle_stats(false)
		end
		if view_name == "inventory_view" and mod:get("auto_show") then
			stats:_toggle_stats(true)
		end
	end
	func(self, view_name, ...)
end)

mod:hook(CLASS.ViewElementPlayerStats, "_generate_stats", function(func, self, ...)
	if mod:get("sort_subs") then
		local ordered_stats, stats_data_by_id = func(self, ...)

		local starting_idxs = {}
		for i = 1, #ordered_stats do
			starting_idxs[ordered_stats[i].id] = i
		end

		table.sort(ordered_stats, function(a, b)
			local a_parent = a.parent
			local a_id = a.id

			local b_parent = b.parent
			local b_id = b.id

			if a_parent == b_id then
				return false
			end
			if b_parent == a_id then
				return true
			end
			if a_parent and b_parent and a_parent == b_parent then
				return Localize(a.title) < Localize(b.title)
			end
			return (starting_idxs[a_id] or 1000) < (starting_idxs[b_id] or 1000)
		end)

		return ordered_stats, stats_data_by_id
	end
	return func(self, ...)
end)

mod:hook(CLASS.ViewElementPlayerStats, "_toggle_stats", function(func, self, ...)
	func(self, ...)
	if self._show_stats and mod:get("auto_expand") then
		local all_stat_ids = {}
		local i = 0
		for id, _ in pairs(self._stat_widgets_by_id) do
			if not self._active_categories_by_id[id] then
				i = i + 1
				all_stat_ids[i] = id

				self._active_categories_by_id[id] = true

				local stat_data = self._stats_data_by_id[id]
				local stat_level = stat_data.level

				self._active_categories_per_level[stat_level] = self._active_categories_per_level[stat_level] or {}

				table.insert(self._active_categories_per_level[stat_level], 1, id)
			end
		end
		self:_update_active_categories({}, all_stat_ids)
	end
end)
