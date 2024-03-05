local mod = get_mod("LoadoutNames")

mod:io_dofile("LoadoutNames/scripts/mods/LoadoutNames/ViewDefinitions")

local tbox_content = nil

mod.set_loadout_name = function(loadout_id, name)
    if loadout_id then
        mod:set(loadout_id, name and name ~= "" and string.sub(name, 1, 25) or nil)
    end
end

mod.get_loadout_name = function(loadout_id, fallback)
    return loadout_id and mod:get(loadout_id) or fallback
end

mod.is_user_typing = function()
    return tbox_content and tbox_content.is_writing
end

mod.end_typing = function()
    if tbox_content then
        tbox_content.is_writing = false
        tbox_content.selected_text = nil
        tbox_content._selection_start = nil
        tbox_content._selection_end = nil
    end
end

local _set_loadout_name_from_ibv = function(inv_back_view, deletion)
    if tbox_content then
        mod.set_loadout_name(inv_back_view._active_profile_preset_id, not deletion and tbox_content.input_text or nil)
    end
end

local _display_loadout_name_to_ibv = function(inv_back_view)
    tbox_content = tbox_content or inv_back_view._widgets_by_name.loadout_tbox.content
    if tbox_content then
        tbox_content.input_text = mod.get_loadout_name(inv_back_view._active_profile_preset_id, "")
    end
end

mod:hook(CLASS.InventoryBackgroundView, "on_enter", function(func, self)
    func(self)
    _display_loadout_name_to_ibv(self)
end)

mod:hook(CLASS.InventoryBackgroundView, "event_on_profile_preset_changed", function(func, self, profile_preset, on_preset_deleted)
    _set_loadout_name_from_ibv(self, on_preset_deleted)
    mod.end_typing()
    func(self, profile_preset, on_preset_deleted)
    _display_loadout_name_to_ibv(self)
end)

mod:hook(CLASS.InventoryBackgroundView, "_handle_input", function(func, self, input_service, dt, t)
    if mod.is_user_typing() and (input_service:get("send_chat_message") or input_service:get("back")) then
        mod.end_typing()
    end
    func(self, input_service, dt, t)
end)

mod:hook(CLASS.InventoryBackgroundView, "on_exit", function(func, self)
    _set_loadout_name_from_ibv(self)
    func(self)
    tbox_content = nil
end)

mod.on_all_mods_loaded = function()
    local hub_hotkeys_mod = get_mod("hub_hotkey_menus")
    if hub_hotkeys_mod then
        mod:hook(hub_hotkeys_mod, "activate_inventory_view", function(func, self)
            if not mod.is_user_typing() then
                func(self)
            end
        end)
    end
end

local _restrict_cb = function(func, ...)
    if not mod.is_user_typing() then
        func(...)
    end
end
mod:hook(CLASS.InventoryBackgroundView, "cb_on_weapon_swap_pressed", _restrict_cb)
mod:hook(CLASS.ViewElementMenuPanel, "_select_next_tab", _restrict_cb)

mod:hook(CLASS.UIManager, "close_view", function(func, self, view_name, force)
    if force or not mod.is_user_typing() or (view_name ~= "inventory_view" and view_name ~= "inventory_background_view" and view_name ~= "talent_builder_view") then
        func(self, view_name, force)
    end
end)
