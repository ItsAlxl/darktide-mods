return function(node_has_points, is_valid_selection)
	local advances = {}
	local laterals = {}

	local _is_lateral = function(tree, candidate_node)
		local children = candidate_node.children
		local num_children = children and #children or 0
		local num_real_children = 0

		if num_children > 0 then
			for c = 1, num_children do
				local child_node = tree:_node_by_name(children[c])
				if child_node then
					if node_has_points(tree, child_node) then
						return true
					end

					local parents = child_node.parents
					local num_parents = parents and #parents or 0
					local num_points_parents = 0
					for p = 1, num_parents do
						local parent_node = tree:_node_by_name(parents[p])
						if parent_node and node_has_points(tree, parent_node) then
							if num_points_parents > 0 then
								return true
							end
							num_points_parents = num_points_parents + 1
						end
					end

					num_real_children = num_real_children + 1
				end
			end
		end

		return num_real_children == 0
	end

	local _explore = function(tree, search_node)
		local search_children = search_node and search_node.children

		if search_children then
			for c = 1, #search_children do
				local child_node = tree:_node_by_name(search_children[c])
				if is_valid_selection(tree, child_node) and not table.contains(advances, child_node) and not table.contains(laterals, child_node) then
					table.insert(
						_is_lateral(tree, child_node) and laterals or advances,
						child_node
					)
				end
			end
		end
	end

	return {
		is_empty = function()
			return #advances == 0 and #laterals == 0
		end,
		start = function(tree, start_node)
			table.clear(advances)
			table.clear(laterals)
			_explore(tree, start_node)
		end,
		next = function()
			return #advances > 0
				and math.random_array_entry(advances)
				or math.random_array_entry(laterals)
		end,
		on_chosen = function(tree, chosen_node)
			_explore(tree, chosen_node)

			for i = #laterals, 1, -1 do
				local n = laterals[i]
				if node_has_points(tree, n) or not is_valid_selection(tree, n) then
					table.remove(laterals, i)
				end
			end

			for i = #advances, 1, -1 do
				local n = advances[i]
				if node_has_points(tree, n) or not is_valid_selection(tree, n) then
					table.remove(advances, i)
				elseif _is_lateral(tree, n) then
					table.insert(laterals, n)
					table.remove(advances, i)
				end
			end
		end
	}
end
