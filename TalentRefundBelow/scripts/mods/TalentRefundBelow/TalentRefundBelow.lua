local mod = get_mod("TalentRefundBelow")

local t_thresholds = {}
local rebuy = {}
local swapping_exclusive = false

local _node_has_points = function(tree, node)
    return (tree._points_spent_on_node_widgets[node.widget_name] or 0) > 0
end

local _node_to_widget = function(tree, node)
    return tree._widgets_by_name[node.widget_name]
end

local _get_node_exclusive_blocker = function(tree, node)
    local exclusive_group = node.requirements.exclusive_group
    if exclusive_group and exclusive_group ~= "" then
        local exlusive_nodes = tree:_nodes_in_exclusive_group(exclusive_group)
        for i = 1, #exlusive_nodes do
            local exlusive_node = exlusive_nodes[i]
            if _node_has_points(tree, exlusive_node) then
                return exlusive_node
            end
        end
    end
    return nil
end

local _remove_dependents = function(tree, node)
    if _node_has_points(tree, node) then
        local children = node.children
        for _, child_name in ipairs(children) do
            local child_node = tree:_node_by_name(child_name)
            if child_node and tree:_is_node_dependent_on_parent(child_node, node) then
                if swapping_exclusive then
                    table.insert(rebuy, child_node)
                end
                tree:_on_node_widget_right_pressed(_node_to_widget(tree, child_node))
            end
        end
    end
end

local _nodes_have_common_bought_child = function(tree, node_a, node_b)
    local children_a = node_a.children
    local children_b = node_b.children
    for _, child_name in ipairs(children_a) do
        local child_node = tree:_node_by_name(child_name)
        if child_node and _node_has_points(tree, child_node) and table.contains(children_b, child_name) then
            return true
        end
    end
    return false
end

local _click_mode_passes = function(mode_key)
    local mode = mod:get(mode_key)
    if mode == 0 then
        return false
    end
    if mode == 1 then
        return true
    end

    local now_t = Managers.time and Managers.time:time("main")
    if now_t then
        if t_thresholds[mode_key] and now_t <= t_thresholds[mode_key] then
            t_thresholds[mode_key] = nil
            return true
        end
        t_thresholds[mode_key] = now_t + mod:get("double_click_window")
    end
    return false
end

mod:hook(CLASS.TalentBuilderView, "_on_node_widget_right_pressed", function(func, self, widget)
    if swapping_exclusive or _click_mode_passes("mode_remove_below") then
        _remove_dependents(self, widget.content.node_data)
    end
    func(self, widget)
end)

mod:hook(CLASS.TalentBuilderView, "_on_node_widget_left_pressed", function(func, self, widget)
    if not swapping_exclusive and _click_mode_passes("mode_exclusive_swap") then
        swapping_exclusive = true
        local node = widget.content.node_data
        local _, spent_in_parents_counter = self:_has_points_spent_in_parents(node)
        if spent_in_parents_counter > 0 then
            local exclusive_blocker = _get_node_exclusive_blocker(self, node)
            if exclusive_blocker and node ~= exclusive_blocker and (not mod:get("require_excl_swap_child") or _nodes_have_common_bought_child(self, node, exclusive_blocker)) then
                table.clear(rebuy)
                self:_on_node_widget_right_pressed(_node_to_widget(self, exclusive_blocker))
                self:_on_node_widget_left_pressed(widget)

                for i = 1, #rebuy do
                    local rebuy_widget = _node_to_widget(self, rebuy[i])
                    self:_on_node_widget_left_pressed(rebuy_widget)

                    -- don't play animations
                    local content = rebuy_widget.content
                    local already_spent_node_points, _ = self:_node_points_by_widget(rebuy_widget)
                    content.has_points_spent = already_spent_node_points > 0
                    content.highlighted = content.has_points_spent
                    content.alpha_anim_progress = content.has_points_spent and 1 or 0
                end
                self._draw_instant_lines = true
            end
        end
        swapping_exclusive = false
    end
    func(self, widget)
end)
