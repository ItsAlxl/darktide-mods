local mod = get_mod("GoToMastery")

local Item_TraitCategory = require("scripts/utilities/items").trait_category
local ITEM_TYPES = require("scripts/settings/ui/ui_settings").ITEM_TYPES
local Promise = require("scripts/foundation/utilities/promise")

local target_travel = nil
local target_return = nil
local target_item = nil
local target_met = false

local safe_close_view = function(view_name)
	local view = Managers.ui:view_instance(view_name)
	if view then
		Managers.ui:close_view(view_name)
	end
end

local get_or_open_view = function(view_name)
	local view = Managers.ui:view_instance(view_name)
	if view then
		return view
	end
	if not Managers.ui:open_view(view_name) then
		return nil
	end
	return Managers.ui:view_instance(view_name)
end

local select_inventory_background_tab = function(view_name)
	local view = get_or_open_view("inventory_background_view")

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

local target_wants_mastery_tab = function(target)
	return target == "mastery_wep"
end

local target_wants_inventory_tab = function(target)
	return target == "inventory_wep"
end

local target_wants_hadron = function(target)
	return target == "hadron_wep"
end

local finish_travel = function()
	target_travel = nil
	target_return = nil
	target_item = nil
	target_met = false
end

local send_from_inventory = function(inventory_view, target)
	finish_travel()
	target_travel = target
	target_return = "inventory_wep"
	target_item = inventory_view._previewed_item
	if target_wants_mastery_tab(target) then
		if not select_inventory_background_tab("masteries_overview_view") then
			finish_travel()
		end
	elseif target_wants_hadron(target) then
		Managers.ui:open_view("crafting_view")
	else
		finish_travel()
	end
end

local send_from_rebless = function(rebless_view, target)
	finish_travel()
	target_travel = target
	target_return = "hadron_wep"
	target_item = rebless_view._item
	if target_wants_mastery_tab(target) then
		Managers.ui:open_view("inventory_background_view")
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

local resize_grid_height = function(grid, layout, button_spacing, padding)
	local num_buttons = 0
	for _, elm in ipairs(layout) do
		if elm.widget_type == "button" then
			num_buttons = num_buttons + 1
		end
	end
	local new_grid_height = (button_spacing) * num_buttons + padding
	grid:update_grid_height(new_grid_height, new_grid_height + padding)
end

-- Add buttons to inventory view
mod:hook_safe(CLASS.InventoryWeaponsView, "on_enter", function(self)
	if self.item_type == ITEM_TYPES.WEAPON_MELEE or self.item_type == ITEM_TYPES.WEAPON_RANGED then
		local grid = self._weapon_options_element
		local layout = grid._visible_grid_layout
		local base_idx = #layout
		layout[base_idx + 1] = {
			display_icon = "",
			widget_type = "button",
			display_name = Localize("loc_mastery_mastery"),
			callback = function() send_from_inventory(self, "mastery_wep") end,
		}
		layout[base_idx + 2] = {
			display_icon = "",
			widget_type = "button",
			display_name = Localize("loc_crafting_view_option_modify"),
			callback = function() send_from_inventory(self, "hadron_wep") end,
		}
		resize_grid_height(grid, layout, self._definitions.blueprints.button.size[2] + 20, 20)
		grid:present_grid_layout(layout, self._definitions.blueprints)
	end
end)

-- Add Mastery button to rebless menu
mod:hook(CLASS.CraftingMechanicusReplaceTraitView, "_create_widgets", function(func, self, defs, ...)
	local ButtonPassTemplates = require("scripts/ui/pass_templates/button_pass_templates")
	local UIWidget = require("scripts/managers/ui/ui_widget")

	defs.widget_definitions.go_to_mastery_button = UIWidget.create_definition(
		ButtonPassTemplates.terminal_button_small,
		"trait_inventory_pivot",
		{
			text = " " .. Localize("loc_mastery_mastery"),
		},
		{
			430,
			40
		}
	)
	func(self, defs, ...)
end)

mod:hook_safe(CLASS.CraftingMechanicusReplaceTraitView, "on_enter", function(self)
	local btn = self._widgets_by_name.go_to_mastery_button
	btn.content.hotspot.pressed_callback = function() send_from_rebless(self, "mastery_wep") end
	btn.offset[1] = 0
	btn.offset[2] = -50
	btn.offset[3] = 1000
end)

-- When entering the mastery view, go to target_item's mastery
mod:hook_safe(CLASS.MasteriesOverviewView, "on_enter", function(self)
	if target_item then
		local master_item = target_item.__master_item
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
		target_met = true
	end
end)

-- When exiting target_item's mastery, return to the source view
mod:hook_safe(CLASS.MasteryView, "on_exit", function(self)
	if target_item then
		if target_wants_inventory_tab(target_return) then
			select_inventory_background_tab("inventory_view")
		elseif target_wants_hadron(target_return) then
			Managers.ui:close_view("inventory_background_view")
			finish_travel()
		end
	end
end)

-- When returning to the inventory view from target_item's mastery, re-enter target_item's slot view
mod:hook_safe(CLASS.InventoryView, "_switch_active_layout", function(self, tab_context)
	if target_item then
		if target_met then
			if target_wants_inventory_tab(target_return) then
				self:cb_on_grid_entry_pressed(nil, find_entry_for_slot(tab_context.layout, target_item.__master_item.slots[1]))
			end
		else
			if target_wants_mastery_tab(target_travel) then
				if not select_inventory_background_tab("masteries_overview_view") then
					finish_travel()
				end
			end
		end
	end
end)

-- If coming back from the mastery view, reselect target_item
mod:hook_safe(CLASS.InventoryWeaponsView, "_present_layout_by_slot_filter", function(self)
	if target_item then
		if target_item ~= self._previewed_item then
			local idx = self:item_grid_index(target_item)
			if idx then
				self:focus_grid_index(idx, self._item_grid:get_scrollbar_percentage_by_index(idx), true)
			end
		end
		finish_travel()
	end
end)

-- When entering the crafting view, go to target_item
mod:hook_safe(CLASS.CraftingView, "on_enter", function(self)
	if target_item then
		-- calling go_to_crafting_view directly results in a crash on exit
		self:on_option_button_pressed(nil, {
			callback = function(crafting_view)
				crafting_view:go_to_crafting_view("select_item_mechanicus", target_item)
			end
		})
		safe_close_view("inventory_background_view")
		finish_travel()
	end
end)
