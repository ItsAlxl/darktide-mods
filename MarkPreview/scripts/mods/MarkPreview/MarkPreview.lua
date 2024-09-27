local mod = get_mod("MarkPreview")

local ViewElementWeaponActionsExtended = require("scripts/ui/view_elements/view_element_weapon_actions/view_element_weapon_actions_extended")

mod:hook_safe(CLASS.InventoryWeaponMarksView, "on_enter", function(self)
	if not self._weapon_actions_extended then
		local layer = 1
		local edge_padding = 4
		local grid_width = 460
		local grid_height = 1000
		local actions_grid = self:_add_element(
			ViewElementWeaponActionsExtended,
			"mkpvw_weapon_actions_extended",
			layer,
			{
				ignore_blur = true,
				scrollbar_width = 7,
				title_height = 70,
				use_parent_world = false,
				grid_spacing = {
					0,
					0,
				},
				grid_size = {
					grid_width - edge_padding,
					grid_height,
				},
				mask_size = {
					grid_width + 40,
					grid_height,
				},
				edge_padding = edge_padding,
			}
		)

		local position = self:_scenegraph_world_position("weapon_stats_pivot")
		actions_grid:set_pivot_offset(position[1] - (grid_width + 50), position[2])
		actions_grid._widgets_by_name.grid_background.style.style_id_1.color[1] = 200

		if self._presentation_item then
			actions_grid:present_item(self._presentation_item)
		end
		actions_grid:set_active(true)

		self._weapon_actions_extended = actions_grid
	end
end)

mod:hook_safe(CLASS.InventoryWeaponMarksView, "_preview_item", function(self, item)
	if self._weapon_actions_extended then
		self._weapon_actions_extended:present_item(item)
	end
end)
