local mod = get_mod("GoToMastery")

local Promise = require("scripts/foundation/utilities/promise")
local Item_TraitCategory = require("scripts/utilities/items").trait_category
local ITEM_TYPES = require("scripts/settings/ui/ui_settings").ITEM_TYPES

local driving_item = nil

local select_inventory_background_tab = function(view_name)
	local view = Managers.ui:view_instance("inventory_background_view")
	if view then
		for idx, settings in ipairs(view._views_settings) do
			if settings.view_name == view_name then
				view:_force_select_panel_index(idx)
				return true
			end
		end
	end
	return false
end

local go_to_mastery = function(self)
	if select_inventory_background_tab("masteries_overview_view") then
		driving_item = self._previewed_item
	end
end

local find_entry_for_slot = function(entries, slot_name)
	for _, e in ipairs(entries) do
		if e.slot.name == slot_name then
			return e
		end
	end
	return nil
end

-- Add "Mastery" button in inventory view
mod:hook_safe(CLASS.InventoryWeaponsView, "on_enter", function(self)
	if self.item_type == ITEM_TYPES.WEAPON_MELEE or self.item_type == ITEM_TYPES.WEAPON_RANGED then
		local grid = self._weapon_options_element
		local new_grid_height = (self._definitions.blueprints.button.size[2] + 20) * 4 + 30
		grid:update_grid_height(new_grid_height, new_grid_height + 30)

		local layout = grid._visible_grid_layout
		layout[#layout + 1] = {
			display_icon = "",
			widget_type = "button",
			display_name = Localize("loc_mastery_mastery"),
			callback = function() go_to_mastery(self) end,
		}
		grid:present_grid_layout(layout, self._definitions.blueprints)
	end
end)

-- When entering the mastery view, go to driving_item's mastery
mod:hook_safe(CLASS.MasteriesOverviewView, "on_enter", function(self)
	if driving_item then
		local master_item = driving_item.__master_item
		local mastery_id = master_item.parent_pattern

		local fetch_promise = self:_mastery_data_available(mastery_id) and Promise.resolved() or self:_fetch_mastery_data(mastery_id)
		fetch_promise:next(function()
			Managers.ui:open_view("mastery_view", nil, nil, nil, nil, {
				mastery = self._masteries[mastery_id],
				traits = self._mastery_traits[mastery_id],
				milestones = self._mastery_milestones[mastery_id],
				slot_type = master_item.slots[1],
				traits_id = Item_TraitCategory(master_item),
				parent = self,
			})
		end)
	end
end)

-- When exiting driving_item's mastery, return to the inventory view
mod:hook_safe(CLASS.MasteryView, "on_exit", function(self)
	if driving_item then
		select_inventory_background_tab("inventory_view")
	end
end)

-- When returning to the inventory view from driving_item's mastery, re-enter driving_item's slot view
mod:hook_safe(CLASS.InventoryView, "_switch_active_layout", function(self, tab_context)
	if driving_item then
		self:cb_on_grid_entry_pressed(nil, find_entry_for_slot(tab_context.layout, driving_item.__master_item.slots[1]))
	end
end)

-- If coming back from the mastery view, reselect driving_item
mod:hook_safe(CLASS.InventoryWeaponsView, "_present_layout_by_slot_filter", function(self)
	if driving_item then
		if driving_item ~= self._previewed_item then
			local idx = self:item_grid_index(driving_item)
			if idx then
				self:focus_grid_index(idx, self._item_grid:get_scrollbar_percentage_by_index(idx), true)
			end
		end
		driving_item = nil
	end
end)
