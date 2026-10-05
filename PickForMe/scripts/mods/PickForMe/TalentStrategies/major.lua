local mod = get_mod("PickForMe")

return function(node_has_points, is_valid_selection)
	local _create_major = function()
		return {
			choices = {},
			pick = nil,
			leg = {},
			spent = false
		}
	end

	local majors = {
		ability = _create_major(),
		aura = _create_major(),
		keystone = _create_major(),
		tactical = _create_major(),
	}

	local search = {}
	local chain = {}
	local leg_visited = {}

	local chain_length = 0
	local chain_idx = 0

	local _reset_major = function(major)
		table.clear(major.choices)
		major.pick = nil
		table.clear(major.leg)
		major.spent = false
	end

	local _leg_from_trace = function(tree, type, start_name)
		local leg = majors[type].leg
		local name = start_name
		while name do
			table.insert(leg, tree:_node_by_name(name))
			name = chain[name]
		end
	end

	-- have to check against excl group (eg cuz of Zealot's undying keystone, which is not exclusive)
	local _get_node_major = function(n)
		local m = majors[n.type]
		local g = n.requirements and n.requirements.exclusive_group
		if m and g and g ~= "" then
			return m
		end
		return nil
	end

	local _find_leg = function(tree, type)
		table.clear(search)
		table.clear(chain)
		table.clear(leg_visited)

		table.insert(search, majors[type].pick)
		while #search > 0 do
			local search_node = table.remove(search, #search)
			local search_name = search_node and search_node.widget_name
			if search_name and not leg_visited[search_name] then
				leg_visited[search_name] = true
				local parents = search_node.parents
				local num_parents = parents and #parents or 0
				for p = 1, num_parents do
					local parent_node = tree:_node_by_name(parents[p])
					if parent_node then
						local parent_name = parent_node.widget_name
						if not leg_visited[parent_name] and not table.contains(search, parent_node) then
							chain[parent_name] = chain[parent_name] or search_name

							local parent_type = parent_node.type
							if parent_type == "start" then
								return _leg_from_trace(tree, type, parent_name)
							end

							local parent_major = _get_node_major(parent_node)
							if parent_major then
								if parent_major.pick == parent_node then
									return _leg_from_trace(tree, type, parent_name)
								end
							else
								table.insert(search, parent_node)
							end
						end
					end
				end
			end
		end
		return nil
	end

	local _is_chain_finished = function()
		return chain_idx > chain_length
	end

	local _explore = function(tree, search_node)
		local search_children = search_node and search_node.children

		if search_children then
			for c = 1, #search_children do
				local child_node = tree:_node_by_name(search_children[c])
				if is_valid_selection(tree, child_node) and not table.contains(child_node) then
					table.insert(search, child_node)
				end
			end
		end
	end

	return {
		is_empty = function()
			return _is_chain_finished() and #search == 0
		end,
		start = function(tree, start_node)
			for _, major in pairs(majors) do
				_reset_major(major)
			end

			local node_widgets = tree._node_widgets
			for i = 1, #node_widgets do
				local n = node_widgets[i].content.node_data
				local m = _get_node_major(n)
				if m then
					table.insert(m.choices, n)
				end
			end

			for _, major in pairs(majors) do
				major.pick = math.random_array_entry(major.choices)
			end

			-- _find_leg depends on every major having a pick
			for type, major in pairs(majors) do
				table.clear(major.leg)
				_find_leg(tree, type)
			end

			table.clear(chain)
			-- can't just chain the legs together sequentially, cuz of mechanicus
			local building_final_chain = true
			while building_final_chain do
				building_final_chain = false
				for _, major in pairs(majors) do
					if not major.spent then
						local leg = major.leg
						local leg_length = #leg
						if leg and leg_length > 0 and (leg[1] == start_node or table.contains(chain, leg[1])) then
							for i = 2, leg_length do
								table.insert(chain, leg[i])
							end
							major.spent = true
							building_final_chain = true
							break
						end
					end
				end
			end

			table.clear(search)
			_explore(tree, start_node)

			chain_length = #chain
			chain_idx = chain_length > 0 and 1 or 0
		end,
		next = function()
			if _is_chain_finished() then
				return math.random_array_entry(search)
			else
				return chain[chain_idx]
			end
		end,
		on_chosen = function(tree, chosen_node)
			if not _is_chain_finished() then
				chain_idx = chain_idx + 1
			end
			_explore(tree, chosen_node)

			for i = #search, 1, -1 do
				local n = search[i]
				if node_has_points(tree, n) or not is_valid_selection(tree, n) then
					table.remove(search, i)
				end
			end
		end,
	}
end
