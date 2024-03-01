local mod = get_mod("InventoryStats")

local Calculate = mod:io_dofile("InventoryStats/scripts/mods/InventoryStats/Calculations")
local CustomPages = mod:io_dofile("InventoryStats/scripts/mods/InventoryStats/CustomPages")
mod:io_dofile("InventoryStats/scripts/mods/InventoryStats/ViewDefinitions")
mod:io_dofile("InventoryStats/scripts/mods/InventoryStats/EquippedOverride")

local UIRenderer = require("scripts/managers/ui/ui_renderer")
local UISoundEvents = require("scripts/settings/ui/ui_sound_events")
local UIWidget = require("scripts/managers/ui/ui_widget")

local VIS_BTN_NAME = "invstat_visbtn"
local PAGE_LEFT_BTN_NAME = "invstat_page_left"
local PAGE_RIGHT_BTN_NAME = "invstat_page_right"

local stats_widgets = {}
local allow_vis = {}

local inv_view = nil
local request_update = false
mod.equip_swap = {}

local vis_menu = false
local vis_data = false
local current_page = 1
local num_allowed_stats = 0

local allow_equip_forces = mod:get("force_equip")

mod.on_all_mods_loaded = function()
    local loadout_names_mod = get_mod("LoadoutNames")
    if loadout_names_mod then
        mod.move_widget_pos(nil, 50, nil)
    end
end

mod.on_setting_changed = function(id)
    if id == "force_equip" then
        allow_equip_forces = mod:get(id)
    elseif table.contains(mod.stat_order, id) then
        local allowed = mod:get(id)
        if allowed then
            num_allowed_stats = num_allowed_stats + 1
        end
        allow_vis[id] = allowed
    end
end

for _, stat in pairs(mod.stat_order) do
    mod.on_setting_changed(stat)
end

local _get_nav_button = function(view, name)
    return view and view._widgets_by_name[name]
end

local _set_nav_btn_vis = function(view, name, vis)
    local btn = _get_nav_button(view, name)
    if btn then
        btn.visible = vis
    end
end

local _fetch_nav_button = function(view, name)
    local widget = _get_nav_button(view, name)
    if view and not widget then
        if name == VIS_BTN_NAME then
            widget = view:_create_widget(name, view._definitions.visbtn_definition)
            widget.content.hotspot.pressed_callback = mod.toggle_data_visible
            widget.content.hotspot.on_hover_sound = UISoundEvents.default_mouse_hover
            widget.content.hotspot.on_pressed_sound = UISoundEvents.default_click
        elseif name == PAGE_LEFT_BTN_NAME then
            widget = view:_create_widget(name, view._definitions.pagenav_definition)
            widget.content.hotspot.pressed_callback = mod.nav_page_left
            widget.content.hotspot.on_hover_sound = UISoundEvents.default_mouse_hover
            widget.content.hotspot.on_pressed_sound = UISoundEvents.default_click
            widget.content.text = "←"
            widget.offset = { 0, 45 }
            widget.visible = false
        elseif name == PAGE_RIGHT_BTN_NAME then
            widget = view:_create_widget(name, view._definitions.pagenav_definition)
            widget.content.hotspot.pressed_callback = mod.nav_page_right
            widget.content.hotspot.on_hover_sound = UISoundEvents.default_mouse_hover
            widget.content.hotspot.on_pressed_sound = UISoundEvents.default_click
            widget.content.text = "→"
            widget.offset = { 155, 45 }
            widget.visible = false
        end
    end
    return widget
end

local _guarantee_stat_widget = function(view, stat_name)
    if not stats_widgets[stat_name] then
        stats_widgets[stat_name] = view:_create_widget("invstat_" .. stat_name, view._definitions.invstat_entry_definition)
        stats_widgets[stat_name].content.title = mod:localize(stat_name)
        stats_widgets[stat_name].visible = false
    end
end

mod.update_inventory_stats = function(view)
    if view ~= nil then
        inv_view = view
    end
    request_update = true
end

mod.is_menu_visible = function()
    return vis_menu
end

mod.is_data_visible = function()
    return mod.is_menu_visible() and vis_data
end

mod.toggle_data_visible = function()
    mod.set_data_visible(not vis_data)
end

mod.set_data_visible = function(v)
    vis_data = v
    mod.update_visibility()
end

mod.update_visibility = function()
    _set_nav_btn_vis(inv_view, VIS_BTN_NAME, vis_menu)

    local stats_vis = mod.is_data_visible()
    _set_nav_btn_vis(inv_view, PAGE_LEFT_BTN_NAME, stats_vis)
    _set_nav_btn_vis(inv_view, PAGE_RIGHT_BTN_NAME, stats_vis)

    if stats_vis then
        mod.update_inventory_stats()
    else
        for _, stat in ipairs(mod.stat_order) do
            if stats_widgets[stat] then
                stats_widgets[stat].visible = false
            end
        end
    end
end

local _move_stat_to_idx = function(stat, idx)
    stats_widgets[stat].visible = true
    stats_widgets[stat].offset[2] = 40 + idx * 40
end

local _update_current_page = function()
    local use_custom_pages = mod:get("use_custom_pages")
    local page_size = mod:get("page_size")
    local num_pages = 0
    if use_custom_pages then
        num_pages = #CustomPages
    else
        num_pages = math.ceil(num_allowed_stats / page_size)
    end
    current_page = current_page % num_pages
    if current_page == 0 then
        current_page = num_pages
    end

    if use_custom_pages then
        for _, stat in ipairs(mod.stat_order) do
            if stats_widgets[stat] then
                stats_widgets[stat].visible = false
            end
        end
        for idx, stat in ipairs(CustomPages[current_page]) do
            if stats_widgets[stat] and allow_vis[stat] then
                _move_stat_to_idx(stat, idx)
            end
        end
    else
        local page_start = ((current_page - 1) * page_size)
        local page_end = current_page * page_size

        local vis_count = 1
        local allowed_idx = 0
        for _, stat in ipairs(mod.stat_order) do
            if stats_widgets[stat] then
                stats_widgets[stat].visible = false
                if allow_vis[stat] then
                    allowed_idx = allowed_idx + 1
                    if allowed_idx > page_start and allowed_idx <= page_end then
                        _move_stat_to_idx(stat, vis_count)
                        vis_count = vis_count + 1
                    end
                end
            end
        end
    end
end

mod.nav_page_left = function()
    current_page = current_page - 1
    _update_current_page()
end

mod.nav_page_right = function()
    current_page = current_page + 1
    _update_current_page()
end

-- The update is handled here to ensure the stats take into account buff changes
-- as an added bonus, it also accumulates updates if several are requested in a frame
mod:hook_safe(CLASS.PlayerUnitBuffExtension, "fixed_update", function(...)
    if not request_update or not inv_view then
        return
    end
    request_update = false

    if not mod.is_data_visible() then
        return
    end

    local plr = inv_view._preview_player
    local plr_unit = plr.player_unit

    local buff_ext = ScriptUnit.has_extension(plr_unit, "buff_system")
    local stat_buffs = buff_ext:stat_buffs()

    local health_ext = ScriptUnit.has_extension(plr_unit, "health_system")
    _guarantee_stat_widget(inv_view, "health")
    _guarantee_stat_widget(inv_view, "wounds")
    if health_ext then
        stats_widgets.health.content.data = health_ext:max_health()
        stats_widgets.wounds.content.data = health_ext:max_wounds()
    end

    local tough_ext = ScriptUnit.has_extension(plr_unit, "toughness_system")
    _guarantee_stat_widget(inv_view, "toughness")
    if tough_ext then
        stats_widgets.toughness.content.data = tough_ext:max_toughness()
    end

    _guarantee_stat_widget(inv_view, "crit_chance")
    _guarantee_stat_widget(inv_view, "crit_dmg")
    if mod.equip_swap.wep then
        stats_widgets.crit_chance.content.data = string.format("%d%%", 100.0 * Calculate.crit_chance(plr, plr_unit) + 0.5)
        stats_widgets.crit_dmg.content.data = Calculate.crit_dmg(stat_buffs)
    end

    local unit_data_ext = ScriptUnit.has_extension(plr_unit, "unit_data_system")
    _guarantee_stat_widget(inv_view, "stamina")
    _guarantee_stat_widget(inv_view, "stamina_regen")

    _guarantee_stat_widget(inv_view, "sprint_speed")
    _guarantee_stat_widget(inv_view, "sprint_time")

    _guarantee_stat_widget(inv_view, "dodge_count")
    _guarantee_stat_widget(inv_view, "dodge_dist")

    _guarantee_stat_widget(inv_view, "tough_regen_delay")
    _guarantee_stat_widget(inv_view, "tough_regen_still")
    _guarantee_stat_widget(inv_view, "tough_regen_moving")
    _guarantee_stat_widget(inv_view, "tough_bounty")
    if unit_data_ext then
        local archetype = unit_data_ext:archetype()
        local stam_template = archetype.stamina
        local tough_template = archetype.toughness
        local max_stamina = Calculate.max_stamina(plr_unit, stam_template)

        stats_widgets.stamina.content.data = max_stamina
        stats_widgets.stamina_regen.content.data = string.format("%.2f", Calculate.stamina_regen(stam_template, stat_buffs))

        stats_widgets.sprint_speed.content.data = string.format("%.2f", Calculate.sprint_speed(plr_unit, archetype.sprint))
        stats_widgets.sprint_time.content.data = string.format("%.2f", Calculate.sprint_time(plr_unit, stat_buffs, max_stamina))

        stats_widgets.dodge_count.content.data = Calculate.dodge_count(plr_unit, stat_buffs)
        stats_widgets.dodge_dist.content.data = string.format("%.2f", Calculate.dodge_dist(plr_unit, archetype.dodge))

        stats_widgets.tough_regen_delay.content.data = string.format("%.2f", Calculate.tough_regen_delay(plr_unit, stat_buffs, tough_template))
        stats_widgets.tough_regen_still.content.data = string.format("%.2f", Calculate.tough_regen(plr_unit, stat_buffs, tough_template, true))
        stats_widgets.tough_regen_moving.content.data = string.format("%.2f", Calculate.tough_regen(plr_unit, stat_buffs, tough_template, false))
        stats_widgets.tough_bounty.content.data = string.format("%.2f", Calculate.tough_bounty(plr_unit, mod.equip_swap.template, stat_buffs, tough_template, tough_ext:max_toughness()))
    end

    _update_current_page()
end)

mod:hook_safe(CLASS.InventoryView, "on_enter", function(self)
    mod.set_data_visible(false)
    mod.update_inventory_stats(self)
end)

mod:hook_safe(CLASS.InventoryView, "_start_animation", function(self, animation_sequence_name, widgets, params, callback, speed, delay)
    if animation_sequence_name == "wallet_on_enter" then
        vis_menu = true
        mod.update_visibility()
    end
    if animation_sequence_name == "wallet_on_exit" then
        vis_menu = false
        mod.update_visibility()
    end
end)

mod:hook_safe(CLASS.InventoryView, "draw", function(self, dt, t, input_service, layer)
    local render_settings = self._render_settings
    local ui_scenegraph = self._ui_scenegraph
    local ui_renderer = self._ui_renderer

    UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt, render_settings)

    UIWidget.draw(_fetch_nav_button(self, VIS_BTN_NAME), ui_renderer)
    UIWidget.draw(_fetch_nav_button(self, PAGE_RIGHT_BTN_NAME), ui_renderer)
    UIWidget.draw(_fetch_nav_button(self, PAGE_LEFT_BTN_NAME), ui_renderer)
    for _, widget in pairs(stats_widgets) do
        UIWidget.draw(widget, ui_renderer)
    end

    UIRenderer.end_pass(ui_renderer)
end)

local _refresh_from_background_view = function(bg_view)
    mod.set_equipped_wep(bg_view._preview_profile_equipped_items[bg_view._preview_wield_slot_id])
end

mod:hook_safe(CLASS.InventoryBackgroundView, "_update_presentation_wield_item", function(self)
    _refresh_from_background_view(self)
end)

local _force_equipment_refresh = function(bg_view)
    if mod.is_data_visible() and allow_equip_forces then
        local promise = bg_view:_equip_local_changes()
        if promise then
            promise:next(function(...)
                _refresh_from_background_view(bg_view)
                bg_view._starting_profile_equipped_items = table.clone(bg_view._current_profile_equipped_items)
            end)
            return
        end
    end
    _refresh_from_background_view(bg_view)
end

mod:hook_safe(CLASS.InventoryBackgroundView, "event_inventory_view_equip_item", function(self, ...)
    _force_equipment_refresh(self)
end)

mod:hook_safe(CLASS.InventoryBackgroundView, "event_on_profile_preset_changed", function(self, ...)
    _force_equipment_refresh(self)
end)
