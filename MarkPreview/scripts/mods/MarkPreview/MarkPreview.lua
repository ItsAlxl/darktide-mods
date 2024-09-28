local mod = get_mod("MarkPreview")

local ViewElementWeaponActionsExtended = require("scripts/ui/view_elements/view_element_weapon_actions/view_element_weapon_actions_extended")
local WeaponStats = require("scripts/utilities/weapon_stats")

mod:hook_safe(CLASS.InventoryWeaponMarksView, "on_enter", function(self)
	if not self._mkpvw_weapon_actions then
		local layer = 1
		local edge_padding = 4
		local grid_width = 460
		local grid_height = 1000
		local actions_grid = self:_add_element(
			ViewElementWeaponActionsExtended,
			"mkpvw_mkpvw_weapon_actions",
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

		actions_grid._mkpvw_extras = true
		self._mkpvw_weapon_actions = actions_grid
	end
end)

mod:hook_safe(CLASS.InventoryWeaponMarksView, "_preview_item", function(self, item)
	if self._mkpvw_weapon_actions then
		self._mkpvw_weapon_actions._mkvpw_item = item
		self._mkpvw_weapon_actions:present_item(item)

		mod.DBG_wae = self._mkpvw_weapon_actions
		mod.DBG_wep_stats = WeaponStats:new(item)
	end
end)

mod:hook(CLASS.ViewElementWeaponActionsExtended, "present_grid_layout", function(func, self, layout)
	if self._mkpvw_extras then
		layout[#layout] = nil

		local weapon_stats = WeaponStats:new(self._mkvpw_item)
		if (weapon_stats._rate_of_fire and weapon_stats._rate_of_fire > 0.0) then
			layout[#layout + 1] = {
				widget_type = "weapon_stat",
				stat = {
					type_data = {
						display_type = "default",
						display_units = "/s",
						display_name = "loc_weapon_stats_display_rate_of_fire",
					},
					value = 1.0 / weapon_stats._rate_of_fire
				},
			}
		end
		if (weapon_stats._reload_time and weapon_stats._reload_time > 0.0) then
			layout[#layout + 1] = {
				widget_type = "weapon_stat",
				stat = {
					type_data = {
						display_type = "default",
						display_units = "s",
						display_name = "loc_basic_reload_input",
					},
					value = weapon_stats._reload_time
				},
			}
		end
		if (weapon_stats._charge_duration and weapon_stats._charge_duration > 0.0) then
			layout[#layout + 1] = {
				widget_type = "weapon_stat",
				stat = {
					type_data = {
						display_type = "default",
						display_units = "s",
						display_name = "loc_weapon_stats_display_charge_speed",
					},
					value = weapon_stats._charge_duration
				},
			}
		end
	end
	func(self, layout)
end)
