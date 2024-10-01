local mod = get_mod("LoadoutNames")
local HubHotkeys = require("scripts/settings/game_mode/game_mode_settings").hub.hotkeys

mod:io_dofile("LoadoutNames/scripts/mods/LoadoutNames/ViewDefinitions")

local MAX_NAME_LENGTH = 50

local is_typing = false
local tooltip_widget = nil
local tbox_widget = nil

local stored_hotkeys = {}

mod.set_loadout_name = function(loadout_id, name)
	if loadout_id then
		mod:set(loadout_id, name and name ~= "" and string.sub(name, 1, MAX_NAME_LENGTH) or nil)
	end
end

mod.get_loadout_name = function(loadout_id, fallback)
	return loadout_id and mod:get(loadout_id) or fallback
end

mod.is_user_typing = function()
	return tbox_widget and is_typing
end

local _remove_vanilla_hotkeys = function()
	stored_hotkeys = {
		hotkey_inventory = HubHotkeys.hotkeys.hotkey_inventory,
		inventory_background_view = HubHotkeys.lookup.inventory_background_view
	}
	HubHotkeys.hotkeys.hotkey_inventory = nil
	HubHotkeys.lookup.inventory_background_view = nil
end

local _restore_vanilla_hotkeys = function()
	HubHotkeys.hotkeys.hotkey_inventory = stored_hotkeys.hotkey_inventory or HubHotkeys.hotkeys.hotkey_inventory
	HubHotkeys.lookup.inventory_background_view = stored_hotkeys.inventory_background_view or HubHotkeys.lookup.inventory_background_view
end

local set_is_typing = function(t)
	if t ~= is_typing then
		is_typing = t

		if t then
			_remove_vanilla_hotkeys()
		else
			_restore_vanilla_hotkeys()
		end

		local tbox_content = tbox_widget and tbox_widget.content
		if tbox_content then
			tbox_content.is_writing = t
			tbox_content.hide_baseline = not t
			tbox_content.selected_text = t and tbox_content.selected_text or nil
			tbox_content._selection_start = t and tbox_content._selection_start or nil
			tbox_content._selection_end = t and tbox_content._selection_end or nil
		end

		local tbox_style = tbox_widget and tbox_widget.style
		if tbox_style then
			tbox_style.background.visible = t
			tbox_style.display_text.text_horizontal_alignment = t and "left" or "right"
		end
	end
end

mod.end_typing = function()
	set_is_typing(false)
end

-- |||
-- set and get loadout names as needed

local _set_loadout_name_from_iv = function(inv_view, deletion)
	if tbox_widget and tbox_widget.content then
		mod.set_loadout_name(inv_view._active_profile_preset_id, not deletion and tbox_widget.content.input_text or nil)
	end
end

local _display_loadout_name_to_iv = function(inv_view)
	tbox_widget = tbox_widget or (inv_view._profile_presets_element and inv_view._profile_presets_element._widgets_by_name.loadout_name_tbox)
	tooltip_widget = tooltip_widget or (inv_view._profile_presets_element and inv_view._profile_presets_element._widgets_by_name.loadout_name_tooltip)
	if tbox_widget and tbox_widget.content then
		tbox_widget.content.input_text = mod.get_loadout_name(inv_view._active_profile_preset_id, "")
	end
end

mod:hook(CLASS.InventoryBackgroundView, "_setup_profile_presets", function(func, self)
	func(self)
	_display_loadout_name_to_iv(self)
end)

mod:hook(CLASS.InventoryBackgroundView, "event_on_profile_preset_changed", function(func, self, profile_preset, on_preset_deleted)
	_set_loadout_name_from_iv(self, on_preset_deleted)
	mod.end_typing()
	func(self, profile_preset, on_preset_deleted)
	_display_loadout_name_to_iv(self)
end)

local _on_cleanup = function(func, self, ...)
	_set_loadout_name_from_iv(self)
	func(self, ...)
	tbox_widget = nil
	tooltip_widget = nil
end
mod:hook(CLASS.InventoryBackgroundView, "_remove_profile_presets", _on_cleanup)
mod:hook(CLASS.InventoryBackgroundView, "on_exit", _on_cleanup)

-- |||
-- UX

mod:hook(CLASS.ViewElementProfilePresets, "update", function(func, self, dt, t, input_service)
	func(self, dt, t, input_service)

	set_is_typing(tbox_widget and tbox_widget.content and tbox_widget.content.is_writing or false)

	local profile_buttons_widgets = self._profile_buttons_widgets
	if tooltip_widget and tooltip_widget.content.text and profile_buttons_widgets then
		local hovered_id = nil
		for i = 1, #profile_buttons_widgets do
			local content = profile_buttons_widgets[i].content
			hovered_id = content.hotspot and content.hotspot.is_hover and content.profile_preset_id or hovered_id
		end

		tooltip_widget.content.text = mod.get_loadout_name(hovered_id, "")
		tooltip_widget.visible = tooltip_widget.content.text ~= ""
	end
end)

mod:hook(CLASS.InventoryBackgroundView, "_handle_input", function(func, self, input_service, dt, t)
	if mod.is_user_typing() and (input_service:get("send_chat_message") or input_service:get("back")) then
		mod.end_typing()
	end
	func(self, input_service, dt, t)
end)

-- |||
-- prevent hotkey callbacks while typing

local _restrict_cb = function(func, ...)
	if not mod.is_user_typing() then
		func(...)
	end
end
mod:hook(CLASS.InventoryBackgroundView, "cb_on_weapon_swap_pressed", _restrict_cb)
mod:hook(CLASS.InventoryBackgroundView, "cb_on_clear_all_talents_pressed", _restrict_cb)
mod:hook(CLASS.ViewElementMenuPanel, "_select_next_tab", _restrict_cb)
