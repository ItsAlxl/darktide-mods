local mod = get_mod("GoToMastery")

local Item_TraitCategory = require("scripts/utilities/items").trait_category
local ITEM_TYPES = require("scripts/settings/ui/ui_settings").ITEM_TYPES
local Input_color_text = require("scripts/managers/input/input_utils").apply_color_to_input_text
local Promise = require("scripts/foundation/utilities/promise")
local ViewElementGrid = require("scripts/ui/view_elements/view_element_grid/view_element_grid")

local back_to_inv_wep = false
local back_to_rebless = false
local going_to_mastery = false
local going_to_sacrifice = false
local target_item = nil

local sacrifice_package_id = nil

local VIEW_NAMES = {
	inventory_root = "inventory_view",
	inventory_bg = "inventory_background_view",
	inventory_list = "inventory_weapons_view",
	mastery_overview = "masteries_overview_view",
	mastery_specific = "mastery_view",
	crafting_root = "crafting_view",
	crafting_select = "crafting_mechanicus_modify_view",
	sacrifice = "crafting_mechanicus_barter_items_view",
}

local safe_open_view = function(view_name)
	local view = Managers.ui:view_instance(view_name)
	if not view then
		Managers.ui:open_view(view_name)
	end
	return view
end

local safe_close_view = function(view_name)
	local view = Managers.ui:view_instance(view_name)
	if view then
		Managers.ui:close_view(view_name)
	end
	return view
end

local force_view_to_top = function(view_name)
	local view = Managers.ui:view_instance(view_name)
	if view then
		Managers.ui._view_handler._gtm_bring_to_top = view_name
	else
		Managers.ui:open_view(view_name)
	end
	return view
end

mod:hook(CLASS.UIViewHandler, "_update_views", function(func, self, ...)
	if self._gtm_bring_to_top then
		local view_name = self._gtm_bring_to_top
		self._gtm_bring_to_top = nil

		local active_views = self._active_views_array
		local top_idx = self._num_active_views
		local found = false
		for i = 1, top_idx - 1 do
			found = found or active_views[i] == view_name
			if found then
				active_views[i] = active_views[i + 1]
			end
		end
		active_views[top_idx] = view_name
	end

	func(self, ...)
end)

local select_inventory_background_tab = function(tab_view_name)
	local inventory_bg = Managers.ui:view_instance(VIEW_NAMES.inventory_bg)
	if inventory_bg and inventory_bg._views_settings then
		for idx, settings in ipairs(inventory_bg._views_settings) do
			if settings.view_name == tab_view_name then
				inventory_bg:_force_select_panel_index(idx)
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
	return target == "hadron_wep" or target == "hadron_sacrifice"
end

local is_outside_hub = function()
	local game_mode_manager = Managers.state.game_mode
	local gamemode_name = game_mode_manager and game_mode_manager:game_mode_name()
	return gamemode_name ~= "hub"
end

local cancel_travel = function()
	back_to_inv_wep = false
	back_to_rebless = false
	going_to_mastery = false
	going_to_sacrifice = false
	target_item = nil
end

-- Add buttons to inventory view, map their hotkeys
local inventory_goto = function(inventory_view, target)
	cancel_travel()
	back_to_inv_wep = true
	target_item = inventory_view._previewed_item
	if target_wants_mastery_tab(target) then
		going_to_mastery = true
		if not select_inventory_background_tab(VIEW_NAMES.mastery_overview) then
			cancel_travel()
		end
	elseif target_wants_hadron(target) then
		going_to_sacrifice = target == "hadron_sacrifice"
		safe_close_view(VIEW_NAMES.inventory_list)
		force_view_to_top(VIEW_NAMES.crafting_root)
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

mod:hook_safe(CLASS.InventoryWeaponsView, "_setup_weapon_options", function(self)
	local is_curio = self.item_type == ITEM_TYPES.GADGET
	mod.showing_curio = is_curio
	if is_curio then
		local button_size = self._definitions.blueprints.button.size
		local top_padding = 30
		local grid_size = {
			button_size[1],
			button_size[2] + top_padding,
		}
		mod.create_curio_options_grid(
			self,
			{
				edge_padding = 40,
				scrollbar_width = 7,
				title_height = 0,
				use_is_focused_for_navigation = false,
				use_select_on_focused = true,
				use_terminal_background = true,
				grid_spacing = {
					10,
					10,
				},
				grid_size = grid_size,
				mask_size = {
					grid_size[1] + 40,
					grid_size[2] + 40,
				},
				top_padding = 30,
			},
			"content/ui/materials/frames/marks_top",
			{
				413.28,
				58.8,
			},
			{
				0,
				-20,
				20,
			}
		)
	end

	local grid = self._weapon_options_element
	if not grid then
		return
	end

	local base_layout = grid._visible_grid_layout or {}
	local base_idx = #base_layout
	base_layout[base_idx + 1] = {
		display_icon = "",
		widget_type = "button",
		display_name = mod.hotkey_data.kb_mastery.display_name,
		callback = function() inventory_goto(self, "mastery_wep") end,
	}
	base_layout[base_idx + 2] = {
		display_icon = "",
		widget_type = "button",
		display_name = mod.hotkey_data.kb_hadron.display_name,
		callback = function() inventory_goto(self, "hadron_wep") end,
		_gtm_curio = true,
	}
	base_layout[base_idx + 3] = {
		display_icon = "",
		widget_type = "button",
		display_name = mod.hotkey_data.kb_sacrifice.display_name,
		callback = function() inventory_goto(self, "hadron_sacrifice") end,
	}

	local layout
	if is_curio then
		layout = {}
		for _, entry in pairs(base_layout) do
			if entry._gtm_curio then
				layout[#layout + 1] = entry
			end
		end
	else
		layout = base_layout
	end

	local display_to_hotkey_id = {}
	for id, data in pairs(mod.hotkey_data) do
		display_to_hotkey_id[data.display_name] = id
		mod.hotkey_data[id].callback = nil
	end

	local show_hotkeys = mod:get("show_hotkeys")
	for _, element in ipairs(layout) do
		local hotkey_id = element.display_name and display_to_hotkey_id[element.display_name]
		if hotkey_id then
			mod.hotkey_data[hotkey_id].callback = element.callback

			if show_hotkeys then
				local keybind = mod:get(hotkey_id)
				if next(keybind) ~= nil then
					element.display_name = Input_color_text("[" .. string.upper(keybind[1]) .. "] ", Color.ui_input_color(255, true)) .. element.display_name
				end
			end
		end
	end

	resize_grid_height(grid, layout, self._definitions.blueprints.button.size[2] + 10, 70)
	grid:present_grid_layout(layout, self._definitions.blueprints)

	-- shorten the text width, in case the text gets too long
	-- also center the icons
	for _, widget in ipairs(grid._grid_widgets) do
		local style = widget.style
		if style.icon then
			style.text.size = { self._definitions.blueprints.button.size[1] - 120, nil }

			style.icon.text_horizontal_alignment = "center"
			style.icon.size = { 50, nil }
			style.icon.offset[1] = 10
		end
	end
end)

mod:hook_safe(CLASS.InventoryWeaponsView, "_preview_item", function(self, item)
	if mod.showing_curio then
		self._weapon_options_element:set_visibility(true)
	end
end)

mod.create_curio_options_grid = function(view, grid_options, top_divider_material, top_divider_size, top_divider_position)
	local grid = view:_add_element(ViewElementGrid, "weapon_options", 10, grid_options)
	grid:update_dividers(top_divider_material, top_divider_size, top_divider_position)
	grid:disable_input(true)
	grid:set_visibility(false)
	view._weapon_options_element = grid
end

local _cb_hotkey = function(hotkey_id)
	local ui_manager = Managers.ui
	if ui_manager:active_top_view() == VIEW_NAMES.inventory_list and not ui_manager:chat_using_input() then
		local hotkey_data = mod.hotkey_data[hotkey_id]
		if hotkey_data and hotkey_data.callback then
			hotkey_data.callback()
		end
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
	if force_view_to_top(VIEW_NAMES.inventory_bg) then
		select_inventory_background_tab(VIEW_NAMES.mastery_overview)
	end
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
			Managers.ui:open_view(VIEW_NAMES.mastery_specific, nil, nil, nil, nil, {
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
			safe_close_view(VIEW_NAMES.inventory_bg)
			back_to_rebless = false
		elseif back_to_inv_wep then
			select_inventory_background_tab(VIEW_NAMES.inventory_root)
		end
	end
end)

-- When returning to the inventory view, re-enter target_item's slot view
local enter_target_slot_list = function(inventory_view, item)
	if inventory_view then
		local widgets = inventory_view._loadout_widgets
		for _, widget in ipairs(widgets) do
			local element = widget.content.element
			local slot = element and element.slot
			if slot and slot.name == item.__master_item.slots[1] then
				inventory_view:cb_on_grid_entry_pressed(nil, element)
				return
			end
		end
	end
end

mod:hook_safe(CLASS.InventoryView, "_switch_active_layout", function(self, tab_context)
	if target_item then
		if going_to_mastery then
			select_inventory_background_tab(VIEW_NAMES.mastery_overview)
		elseif back_to_inv_wep then
			enter_target_slot_list(self, target_item)
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
		if going_to_sacrifice then
			self:on_option_button_pressed(nil, {
				callback = function(crafting_view)
					crafting_view:go_to_crafting_view("barter_items_mechanicus")
				end
			})
		else
			self:on_option_button_pressed(nil, {
				callback = function(crafting_view)
					crafting_view:go_to_crafting_view("select_item_mechanicus", target_item)
				end
			})
		end
	end
end)

-- When entering the sacrifice menu, go to target_item's sacrifice
mod:hook_safe(CLASS.CraftingMechanicusBarterItemsView, "_setup_menu_tabs", function(self)
	if target_item and going_to_sacrifice then
		local master_item = target_item.__master_item
		local mastery_id = master_item.parent_pattern

		if master_item.slots[1] == "slot_secondary" then
			self:cb_switch_tab(2)
		end

		for _, widget in ipairs(self._patterns_grid._grid_widgets) do
			if widget.content.element.mastery_id == mastery_id then
				self:cb_pattern_on_grid_entry_left_pressed(widget, widget.content.element)
				--self:_change_state("sacrifice_weapon") -- this doesn't work and I dunno why
				going_to_sacrifice = false
				return
			end
		end
	end
end)

-- When exiting the item crafting view, return to inventory
local _return_to_inv_from_crafting = function(...)
	local top_view = Managers.ui:active_top_view()
	mod:info("SCT: Exited top view " .. top_view)
	if target_item and (top_view == VIEW_NAMES.crafting_select or top_view == VIEW_NAMES.sacrifice) then
		mod:info("SCT: back to crafting root")
		if back_to_inv_wep then
			mod:info("SCT: let's return to the inventory")
			safe_close_view(VIEW_NAMES.crafting_root)
			safe_open_view(VIEW_NAMES.inventory_bg)
			select_inventory_background_tab(VIEW_NAMES.inventory_root)
			enter_target_slot_list(Managers.ui:view_instance(VIEW_NAMES.inventory_root), target_item)
			mod:info("SCT: should have returned to the inventory by now")
		else
			cancel_travel()
		end
	end
end
mod:hook_safe(CLASS.CraftingMechanicusBarterItemsView, "on_exit", _return_to_inv_from_crafting)
mod:hook_safe(CLASS.CraftingMechanicusModifyView, "on_exit", _return_to_inv_from_crafting)

-- Update target item according to selection in crafting menu
mod:hook_safe(CLASS.CraftingView, "start_present_item", function(self, item)
	target_item = target_item and item
end)

-- prevent crash when sacrificing from outside the hub
mod:hook(CLASS.CraftingMechanicusBarterItemsView, "_setup_background_world", function(func, self)
	if is_outside_hub() then
		sacrifice_package_id = sacrifice_package_id or Managers.package:load("packages/ui/views/masteries_overview_view/masteries_overview_view", mod.name, nil, true)
		return
	end
	func(self)
end)

-- release the sacrifice package when leaving the crafting view
mod:hook_safe(CLASS.CraftingView, "on_exit", function(self)
	if sacrifice_package_id then
		Managers.package:release(sacrifice_package_id)
		sacrifice_package_id = nil
	end
	mod:info("SCT: Exited crafting view")
end)

-- Help pinpoint the crash when returning from sacrifice
mod:hook_safe(CLASS.CraftingMechanicusBarterItemsView, "on_enter", function(self)
	mod:info("SCT: Entered barter view")
end)

mod:hook_safe(CLASS.CraftingMechanicusBarterItemsView, "_create_ui_renderer", function(self, ...)
	mod:info("SCT: Barter using external renderer: %s", self._ui_renderer_is_external)
	mod:info("SCT: Barter renderer gui: %s", self._ui_renderer and self._ui_renderer.gui)
end)
