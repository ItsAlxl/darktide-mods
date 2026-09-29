local mod = get_mod("TalentRefundBelow")

local click_checks = {}

local _click_mode_passes = function(key, widget)
	local mode = mod:get(key)
	if mode == 0 then
		return false
	end
	if mode == 1 then
		return true
	end

	local now_t = Managers.time and Managers.time:time("main")
	if now_t then
		if click_checks[key] and now_t <= click_checks[key].t and widget == click_checks[key].w then
			click_checks[key] = nil
			return true
		end
		click_checks[key] = {
			t = now_t + mod:get("double_click_window"),
			w = widget
		}
	end
	return false
end

local _node_has_points = function(tree, node)
	return (tree._node_widget_tiers[node.widget_name] or 0) > 0
end

local _node_to_widget = function(tree, node)
	return tree._widgets_by_name[node.widget_name]
end

local _get_node_exclusive_blocker = function(tree, node)
	local exclusive_group = node.requirements.exclusive_group
	if exclusive_group and exclusive_group ~= "" then
		local exclusive_nodes = tree:_nodes_in_exclusive_group(exclusive_group)
		for i = 1, #exclusive_nodes do
			local exclusive_node = exclusive_nodes[i]
			if _node_has_points(tree, exclusive_node) then
				return exclusive_node
			end
		end
	end
	return nil
end

local _is_deadend = function(tree, node)
	local children = node.children
	for c = 1, #children do
		local child_node = tree:_node_by_name(children[c])
		if child_node and tree:_is_node_dependent_on_parent(child_node, node) then
			return false
		end
	end
	return true
end

local _is_sibling_swappable = function(tree, node, sibling)
	if _node_has_points(tree, sibling) then
		if _is_deadend(tree, sibling) then
			return true
		end

		local node_children = node.children
		local sib_children = sibling.children
		for c = 1, #sib_children do
			local sib_child_name = sib_children[c]
			local sib_child_node = tree:_node_by_name(sib_child_name)
			if sib_child_node
				and sib_child_node ~= node
				and tree:_is_node_dependent_on_parent(sib_child_node, sibling)
				and table.contains(node_children, sib_child_name) then
				return true
			end
		end
	end
	return false
end

local _find_swappable_sibling = function(tree, node)
	local parents = node.parents
	if parents then
		for p = 1, #parents do
			local parent_node = tree:_node_by_name(parents[p])
			if parent_node and _node_has_points(tree, parent_node) then
				local sibs = parent_node.children
				for s = 1, #sibs do
					local sib_node = tree:_node_by_name(sibs[s])
					if sib_node and sib_node ~= node and _is_sibling_swappable(tree, node, sib_node) then
						return sib_node
					end
				end
			end
		end
	end
	return nil
end

local _remove_dependents = function(tree, root_node, condition)
	local target_nodes = { root_node }

	while #target_nodes > 0 do
		local work_node = table.remove(target_nodes, 1)
		local children = work_node.children
		for c = 1, #children do
			local descendant = tree:_node_by_name(children[c])
			if descendant
				and _node_has_points(tree, descendant)
				and (condition == nil or condition(descendant))
				and tree:_is_node_dependent_on_parent(descendant, root_node)
			then
				table.insert(target_nodes, descendant)
				tree:_remove_node_point_on_widget(_node_to_widget(tree, descendant))
			end
		end
	end
end

local _take_talent_on_widget = function(tree, widget)
	tree:_add_node_point_on_widget(widget, 1)
end

mod:hook(CLASS.TalentBuilderView, "_on_node_widget_right_pressed", function(func, self, widget)
	if self._is_own_player then
		local node = widget.content.node_data
		if _click_mode_passes("remove_dependents", widget) then
			-- if it's an empty node, buy it to make dependency meaningful
			if not _node_has_points(self, node) and self:_points_available() > 0 then
				_take_talent_on_widget(self, widget)
			end

			-- don't perform dependent removal on an empty node when all points are spent
			if _node_has_points(self, node) then
				_remove_dependents(self, node)
			end
		end
	end
	func(self, widget)
end)

mod:hook(CLASS.TalentBuilderView, "_on_node_widget_left_pressed", function(func, self, widget)
	if self._is_own_player then
		local node = widget.content.node_data
		if not _node_has_points(self, node) and _click_mode_passes("swap_exclusives", widget) then
			local _, spent_in_parents_counter = self:_has_points_spent_in_parents(node)
			if spent_in_parents_counter > 0 then
				local exclusive_blocker = _get_node_exclusive_blocker(self, node)
				if exclusive_blocker and node ~= exclusive_blocker then
					self:_remove_node_point_on_widget(_node_to_widget(self, exclusive_blocker))
					_take_talent_on_widget(self, widget)
				elseif self:_points_available() == 0 and mod:get("swap_siblings") then
					local swap_sib = _find_swappable_sibling(self, node)
					if swap_sib then
						self:_remove_node_point_on_widget(_node_to_widget(self, swap_sib))
						_take_talent_on_widget(self, widget)
					end
				end
			end
		end
	end
	func(self, widget)
end)
