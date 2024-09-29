local mod = get_mod("GoToMastery")

local Item_TraitCategory = require("scripts/utilities/items").trait_category
local ITEM_TYPES = require("scripts/settings/ui/ui_settings").ITEM_TYPES
local Input_color_text = require("scripts/managers/input/input_utils").apply_color_to_input_text
local Promise = require("scripts/foundation/utilities/promise")

local going_to_mastery = false
local back_to_inv_wep = false
local back_to_rebless = false
local target_item = nil

local sacrifice_package_id = nil

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

local target_wants_hadron = function(target)
	return target == "hadron_wep"
end

local is_outside_hub = function()
	return Managers.state.game_mode:game_mode_name() ~= "hub"
end

local cancel_travel = function()
	back_to_inv_wep = false
	back_to_rebless = false
	going_to_mastery = false
	target_item = nil
end

-- Add buttons to inventory view, map their hotkeys
local inventory_goto = function(inventory_view, target)
	cancel_travel()
	back_to_inv_wep = true
	target_item = inventory_view._previewed_item
	if target_wants_mastery_tab(target) then
		going_to_mastery = true
		if not select_inventory_background_tab("masteries_overview_view") then
			cancel_travel()
		end
	elseif target_wants_hadron(target) then
		Managers.ui:open_view("crafting_view")
	else
		cancel_travel()
	end
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

mod:hook_safe(CLASS.InventoryWeaponsView, "on_enter", function(self)
	if self.item_type == ITEM_TYPES.WEAPON_MELEE or self.item_type == ITEM_TYPES.WEAPON_RANGED then
		local grid = self._weapon_options_element
		local layout = grid._visible_grid_layout
		local base_idx = #layout
		layout[base_idx + 1] = {
			display_icon = "",
			widget_type = "button",
			display_name = mod.hotkey_data.kb_mastery.display_name,
			callback = function() inventory_goto(self, "mastery_wep") end,
		}
		layout[base_idx + 2] = {
			display_icon = "",
			widget_type = "button",
			display_name = mod.hotkey_data.kb_hadron.display_name,
			callback = function() inventory_goto(self, "hadron_wep") end,
		}

		local display_to_hotkey_id = {}
		for id, data in pairs(mod.hotkey_data) do
			display_to_hotkey_id[data.display_name] = id
		end
		for _, element in ipairs(layout) do
			local hotkey_id = display_to_hotkey_id[element.display_name]
			mod.hotkey_data[hotkey_id].callback = element.callback

			local keybind = mod:get(hotkey_id)
			if next(keybind) ~= nil then
				element.display_name = Input_color_text("[" .. string.upper(keybind[1]) .. "] ", Color.ui_input_color(255, true)) .. element.display_name
			end
		end

		resize_grid_height(grid, layout, self._definitions.blueprints.button.size[2] + 20, 20)
		grid:present_grid_layout(layout, self._definitions.blueprints)

		-- shorten the text width, in case users supply long hotkeys
		for _, widget in ipairs(grid._grid_widgets) do
			widget.style.text.size = { self._definitions.blueprints.button.size[1] - 120, nil }
		end
	end
end)

local _cb_hotkey = function(hotkey_id)
	if Managers.ui:active_top_view() == "inventory_weapons_view" then
		mod.hotkey_data[hotkey_id].callback()
	end
end

for id, data in pairs(mod.hotkey_data) do
	mod[data.function_name] = function(...) _cb_hotkey(id) end
end

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

local rebless_goto_mastery = function(rebless_view)
	back_to_rebless = true
	going_to_mastery = true
	target_item = rebless_view._item
	Managers.ui:open_view("inventory_background_view")
end

mod:hook_safe(CLASS.CraftingMechanicusReplaceTraitView, "on_enter", function(self)
	local btn = self._widgets_by_name.go_to_mastery_button
	btn.content.hotspot.pressed_callback = function() rebless_goto_mastery(self) end
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
	end
end)

-- When exiting target_item's mastery, return to the source view
mod:hook_safe(CLASS.MasteryView, "on_exit", function(self)
	if target_item then
		going_to_mastery = false
		if back_to_rebless then
			Managers.ui:close_view("inventory_background_view")
			back_to_rebless = false
		elseif back_to_inv_wep then
			select_inventory_background_tab("inventory_view")
		end
	end
end)

-- When returning to the inventory view, re-enter target_item's slot view
local find_entry_for_slot = function(entries, slot_name)
	for _, e in ipairs(entries) do
		if e.slot.name == slot_name then
			return e
		end
	end
	return nil
end

mod:hook_safe(CLASS.InventoryView, "_switch_active_layout", function(self, tab_context)
	if target_item then
		if going_to_mastery then
			select_inventory_background_tab("masteries_overview_view")
		elseif back_to_inv_wep then
			self:cb_on_grid_entry_pressed(nil, find_entry_for_slot(tab_context.layout, target_item.__master_item.slots[1]))
			back_to_inv_wep = false
		end
	end
end)

-- When returning to the inventory view, reselect target_item
mod:hook_safe(CLASS.InventoryWeaponsView, "_present_layout_by_slot_filter", function(self)
	if target_item then
		if target_item ~= self._previewed_item then
			local idx = self:item_grid_index(target_item)
			if idx then
				self:focus_grid_index(idx, self._item_grid:get_scrollbar_percentage_by_index(idx), true)
			end
		end
		cancel_travel()
	end
end)

-- When entering the crafting view, go to target_item
mod:hook_safe(CLASS.CraftingView, "on_enter", function(self)
	if target_item then
		-- calling go_to_crafting_view directly results in a crash on exit (h/t Zombine)
		self:on_option_button_pressed(nil, {
			callback = function(crafting_view)
				crafting_view:go_to_crafting_view("select_item_mechanicus", target_item)
			end
		})
		safe_close_view("inventory_background_view")
	end
end)

-- When exiting the crafting view, return to inventory
mod:hook_safe(CLASS.CraftingView, "on_exit", function(self)
	if target_item then
		if back_to_inv_wep then
			Managers.ui:open_view("inventory_background_view")
		else
			cancel_travel()
		end
	end

	-- release the sacrifice package if outside the hub
	if sacrifice_package_id then
		Managers.package:release(sacrifice_package_id)
		sacrifice_package_id = nil
	end
end)

-- Update target item according to selection in crafting menu
mod:hook_safe(CLASS.CraftingView, "start_present_item", function(self, item)
	target_item = target_item and item
end)

-- prevent crash when sacrificing from outside the hub
mod:hook(CLASS.CraftingMechanicusBarterItemsView, "_setup_background_world", function(func, self)
	if is_outside_hub() then
		sacrifice_package_id = not sacrifice_package_id and Managers.package:load("packages/ui/views/masteries_overview_view/masteries_overview_view", mod.name, nil, true)
		return
	end
	func(self)
end)
