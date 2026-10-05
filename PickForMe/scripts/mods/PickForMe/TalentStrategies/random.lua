return function(node_has_points, is_valid_selection)
	local candidates = {}

	local _explore = function(tree, search_node)
		local search_children = search_node and search_node.children

		if search_children then
			for c = 1, #search_children do
				local child_node = tree:_node_by_name(search_children[c])
				if is_valid_selection(tree, child_node) and not table.contains(child_node) then
					table.insert(candidates, child_node)
				end
			end
		end
	end

	return {
		is_empty = function()
			return #candidates == 0
		end,
		start = function(tree, start_node)
			table.clear(candidates)
			_explore(tree, start_node)
		end,
		next = function()
			return math.random_array_entry(candidates)
		end,
		on_chosen = function(tree, chosen_node)
			_explore(tree, chosen_node)

			for i = #candidates, 1, -1 do
				local n = candidates[i]
				if node_has_points(tree, n) or not is_valid_selection(tree, n) then
					table.remove(candidates, i)
				end
			end
		end
	}
end
