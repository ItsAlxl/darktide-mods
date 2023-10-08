local mod = get_mod("TalentRefundBelow")

local removed_nodes = {}

mod.DBG_remnodes = removed_nodes

local click_checks = {}
local currently_swapping = false
local currently_removing = false

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
    return (tree._points_spent_on_node_widgets[node.widget_name] or 0) > 0
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

local _find_deadend_node = function(tree)
    for name, points in pairs(tree._points_spent_on_node_widgets) do
        local node = tree:_node_by_name(name)
        if points > 0 and _is_deadend(tree, node) then
            return node
        end
    end
    return nil
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
            if sib_child_node and sib_child_node ~= node and tree:_is_node_dependent_on_parent(sib_child_node, sibling) and table.contains(node_children, sib_child_name) then
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

mod:hook(CLASS.TalentBuilderView, "_on_node_widget_right_pressed", function(func, self, widget)
    if not currently_removing and (currently_swapping or _click_mode_passes("mode_remove_below", widget)) then
        currently_removing = true
        local root_node = widget.content.node_data
        if _node_has_points(self, root_node) then
            table.clear(removed_nodes)
            table.insert(removed_nodes, root_node)

            local i = 1
            while i <= #removed_nodes do
                local work_node = removed_nodes[i]
                local children = work_node.children
                for c = 1, #children do
                    local child_node = self:_node_by_name(children[c])
                    if child_node and not table.contains(removed_nodes, child_node) and self:_is_node_dependent_on_parent(child_node, root_node) then
                        table.insert(removed_nodes, child_node)
                    end
                end
                i = i + 1
            end

            for r = #removed_nodes, 2, -1 do
                self:_on_node_widget_right_pressed(_node_to_widget(self, removed_nodes[r]))
            end
        end
        currently_removing = false
    end
    func(self, widget)
end)

local _attempt_rebuy_node = function(tree, node)
    if node then
        local rebuy_widget = _node_to_widget(tree, node)
        tree:_on_node_widget_left_pressed(rebuy_widget)

        -- don't play animations
        local content = rebuy_widget.content
        local already_spent_node_points, _ = tree:_node_points_by_widget(rebuy_widget)
        content.has_points_spent = already_spent_node_points > 0
        content.highlighted = content.has_points_spent
        content.alpha_anim_progress = content.has_points_spent and 1 or 0
    end
end

local function _rebuy_traversal(tree, root, pool)
    if root then
        local children = root.children
        for c = 1, #children do
            local child_name = children[c]
            local child_node = tree:_node_by_name(child_name)
            if child_node and pool[child_node] then
                pool[child_node] = nil
                _attempt_rebuy_node(tree, child_node)
                _rebuy_traversal(tree, child_node, pool)
            end
        end
    end
end

mod:hook(CLASS.TalentBuilderView, "_on_node_widget_left_pressed", function(func, self, widget)
    if not currently_swapping and _click_mode_passes("mode_exclusive_swap", widget) then
        currently_swapping = true
        local node = widget.content.node_data
        local _, spent_in_parents_counter = self:_has_points_spent_in_parents(node)
        if spent_in_parents_counter > 0 then
            local exclusive_blocker = _get_node_exclusive_blocker(self, node)
            if exclusive_blocker and node ~= exclusive_blocker then
                self:_on_node_widget_right_pressed(_node_to_widget(self, exclusive_blocker))
                self:_on_node_widget_left_pressed(widget)

                local rebuy_nodes = {}
                for r = 1, #removed_nodes do
                    rebuy_nodes[removed_nodes[r]] = true
                end
                _rebuy_traversal(self, node, rebuy_nodes)
                self._draw_instant_lines = true
            elseif self:_points_available() == 0 and mod:get("swap_siblings") then
                local swap_sib = _find_swappable_sibling(self, node)
                if swap_sib then
                    local deadend_node = _find_deadend_node(self)

                    self:_on_node_widget_right_pressed(_node_to_widget(self, deadend_node))
                    self:_on_node_widget_left_pressed(widget)
                    self:_on_node_widget_right_pressed(_node_to_widget(self, swap_sib))

                    _attempt_rebuy_node(self, deadend_node)
                    self._draw_instant_lines = true
                end
            end
        end
        currently_swapping = false
    end
    func(self, widget)
end)
