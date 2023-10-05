local mod = get_mod("TalentRefundBelow")

mod:hook(CLASS.NodeBuilderViewBase, "_on_node_widget_right_pressed", function(func, self, widget)
    local node = widget.content.node_data
    local widgets_by_name = self._widgets_by_name

    for _, child_name in ipairs(node.children) do
        local child_node = self:_node_by_name(child_name)
        if child_node and self:_is_node_dependent_on_parent(child_node, node) then
            self:_on_node_widget_right_pressed(widgets_by_name[child_node.widget_name])
        end
    end

    func(self, widget)
end)
