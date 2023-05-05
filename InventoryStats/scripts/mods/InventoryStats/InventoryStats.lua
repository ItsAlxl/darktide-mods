local mod = get_mod("InventoryStats")
mod:io_dofile("InventoryStats/scripts/mods/InventoryStats/ViewDefinitions")
mod:io_dofile("InventoryStats/scripts/mods/InventoryStats/EquippedOverride")

local BuffSettings = require("scripts/settings/buff/buff_settings")
local CriticalStrike = require("scripts/utilities/attack/critical_strike")
local Stamina = require("scripts/utilities/attack/stamina")
local UIRenderer = require("scripts/managers/ui/ui_renderer")
local UIWidget = require("scripts/managers/ui/ui_widget")
local Weapon = require("scripts/extension_systems/weapon/weapon")
local WeaponTemplate = require("scripts/utilities/weapon/weapon_template")

local EMPTY_TABLE = {}

local stats_widgets = {}
local stat_order = {
    "health",
    "wounds",
    "toughness",
    "crit_chance",
    "crit_dmg",
    "stamina",
    "stamina_regen",
    "sprint_speed",
    "sprint_time",
}

local cached_inv_view = nil
local request_update = false
mod.equip_swap = {}

local _is_wep_ranged = function()
    if not mod.equip_swap.template then
        return false
    end
    return WeaponTemplate.is_ranged(mod.equip_swap.template)
end

local _is_wep_melee = function()
    if not mod.equip_swap.template then
        return false
    end
    return WeaponTemplate.is_melee(mod.equip_swap.template)
end

local _calculate_crit_chance = function(plr, plr_unit)
    return CriticalStrike.chance(plr, ScriptUnit.has_extension(plr_unit, "weapon_system"):weapon_handling_template() or EMPTY_TABLE, _is_wep_ranged(), _is_wep_melee())
end

local _calculate_crit_dmg = function(stat_buffs)
    local critical_damage = stat_buffs.critical_strike_damage or 1
    local ranged_critical_damage = _is_wep_ranged() and stat_buffs.ranged_critical_strike_damage or 1
    local melee_critical_damage = _is_wep_melee() and stat_buffs.melee_critical_strike_damage or 1
    return critical_damage + ranged_critical_damage + melee_critical_damage - 2
end

local _calculate_max_stamina = function(unit, stam_template)
    local _, max = Stamina.current_and_max_value(unit, { current_fraction = 1 }, stam_template)
    return max
end

local _calculate_stamina_regen = function(stam_template, stat_buffs)
    return stam_template.regeneration_per_second * stat_buffs.stamina_regeneration_modifier * stat_buffs.stamina_regeneration_multiplier
end

local _calculate_sprint_speed = function(plr_unit, sprint_template)
    local wep_sprint_template = ScriptUnit.has_extension(plr_unit, "weapon_system"):sprint_template()
    return sprint_template.sprint_move_speed + (wep_sprint_template and wep_sprint_template.sprint_speed_mod or 1)
end

local _calculate_sprint_time = function(plr_unit, stat_buffs, max_stamina)
    local wep_stam_template = ScriptUnit.has_extension(plr_unit, "weapon_system"):stamina_template()
    return max_stamina / ((wep_stam_template and wep_stam_template.sprint_cost_per_second or math.huge) * stat_buffs.sprinting_cost_multiplier)
end

local _guarantee_stat_widget = function(view, stat_name)
    local definition = view._definitions.invstat_entry_definition
    if not stats_widgets[stat_name] then
        stats_widgets[stat_name] = view:_create_widget("invstat_" .. stat_name, definition)
        stats_widgets[stat_name].content.title = mod:localize(stat_name)
        stats_widgets[stat_name].visible = false
    end
end

mod.set_equipped_wep = function(w)
    if w == mod.equip_swap.wep then
        return
    end
    if w then
        mod.equip_swap.template = WeaponTemplate.weapon_template_from_item(w)
        mod.equip_swap.tweaks, _, _, _ = Weapon._init_traits(nil, mod.equip_swap.template, w, nil, nil)
        mod.equip_swap.wep = w
    else
        mod.equip_swap.template = nil
        mod.equip_swap.tweaks = nil
        mod.equip_swap.wep = nil
    end
    mod.update_inventory_stats()
end

mod.update_inventory_stats = function(view)
    if view ~= nil then
        cached_inv_view = view
    end
    request_update = true
end

mod:hook_safe(CLASS.PlayerUnitBuffExtension, "fixed_update", function(self, unit, dt, t, fixed_frame)
    if not request_update or not cached_inv_view then
        return
    end
    request_update = false

    local plr = cached_inv_view._preview_player
    local plr_unit = plr.player_unit

    local buff_ext = ScriptUnit.has_extension(plr_unit, "buff_system")
    local stat_buffs = buff_ext:stat_buffs()

    local param_table = buff_ext:request_proc_event_param_table()
    if param_table then
        param_table.weapon_template = mod.equip_swap.template

        buff_ext:add_proc_event(BuffSettings.proc_events.on_wield, param_table)
        if _is_wep_ranged() then
            buff_ext:add_proc_event(BuffSettings.proc_events.on_wield_ranged, param_table)
        end
        if _is_wep_melee() then
            buff_ext:add_proc_event(BuffSettings.proc_events.on_wield_melee, param_table)
        end
    end

    local health_ext = ScriptUnit.has_extension(plr_unit, "health_system")
    _guarantee_stat_widget(cached_inv_view, "health")
    _guarantee_stat_widget(cached_inv_view, "wounds")
    stats_widgets.health.visible = health_ext ~= nil
    stats_widgets.wounds.visible = health_ext ~= nil
    if health_ext then
        stats_widgets.health.content.data = health_ext:max_health()
        stats_widgets.wounds.content.data = health_ext:max_wounds()
    end

    local tough_ext = ScriptUnit.has_extension(plr_unit, "toughness_system")
    _guarantee_stat_widget(cached_inv_view, "toughness")
    stats_widgets.toughness.visible = tough_ext ~= nil
    if tough_ext then
        stats_widgets.toughness.content.data = tough_ext:max_toughness()
    end

    _guarantee_stat_widget(cached_inv_view, "crit_chance")
    _guarantee_stat_widget(cached_inv_view, "crit_dmg")
    stats_widgets.crit_chance.visible = mod.equip_swap.wep ~= nil
    stats_widgets.crit_dmg.visible = mod.equip_swap.wep ~= nil
    if mod.equip_swap.wep then
        stats_widgets.crit_chance.content.data = string.format("%d%%", 100.0 * _calculate_crit_chance(plr, plr_unit) + 0.5)
        stats_widgets.crit_dmg.content.data = _calculate_crit_dmg(stat_buffs)
    end

    local unit_data_ext = ScriptUnit.has_extension(plr_unit, "unit_data_system")
    _guarantee_stat_widget(cached_inv_view, "stamina")
    _guarantee_stat_widget(cached_inv_view, "stamina_regen")
    stats_widgets.stamina.visible = unit_data_ext ~= nil
    stats_widgets.stamina_regen.visible = unit_data_ext ~= nil

    _guarantee_stat_widget(cached_inv_view, "sprint_speed")
    _guarantee_stat_widget(cached_inv_view, "sprint_time")
    stats_widgets.sprint_speed.visible = unit_data_ext ~= nil
    stats_widgets.sprint_time.visible = unit_data_ext ~= nil

    if unit_data_ext then
        local spec = unit_data_ext:specialization()
        local stam_template = spec.stamina
        local max_stamina = _calculate_max_stamina(plr_unit, stam_template)
        stats_widgets.stamina.content.data = max_stamina
        stats_widgets.stamina_regen.content.data = string.format("%.2f", _calculate_stamina_regen(stam_template, stat_buffs))
        stats_widgets.sprint_speed.content.data = string.format("%.2f", _calculate_sprint_speed(plr_unit, spec.sprint))
        stats_widgets.sprint_time.content.data = string.format("%.2f", _calculate_sprint_time(plr_unit, stat_buffs, max_stamina))
    end

    local vis_count = 0
    for _, stat in ipairs(stat_order) do
        if stats_widgets[stat] and stats_widgets[stat].visible then
            stats_widgets[stat].offset[2] = vis_count * 40
            vis_count = vis_count + 1
        end
    end
end)

mod:hook_safe(CLASS.InventoryView, "on_enter", function(self)
    mod.update_inventory_stats(self)
end)

local _get_stat_widget_list = function()
    local list = {}
    --for i = #stat_order, 1, -1 do
    for i = 1, #stat_order do
        list[#list + 1] = stats_widgets[stat_order[i]]
    end
    return list
end

mod:hook_safe(CLASS.InventoryView, "_start_animation", function(self, animation_sequence_name, widgets, params, callback, speed, delay)
    if animation_sequence_name == "wallet_on_enter" then
        self:_start_animation("invstat_on_enter", _get_stat_widget_list(), params, callback, speed, delay)
    end
    if animation_sequence_name == "wallet_on_exit" then
        self:_start_animation("invstat_on_exit", _get_stat_widget_list(), params, callback, speed, delay)
    end
end)

mod:hook_safe(CLASS.InventoryView, "draw", function(self, dt, t, input_service, layer)
    local render_settings = self._render_settings
    local ui_scenegraph = self._ui_scenegraph
    local ui_renderer = self._ui_renderer

    UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt, render_settings)

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

mod:hook_safe(CLASS.InventoryBackgroundView, "_equip_slot_item", function(self, ...)
    local promise = self:_equip_local_changes()
    if promise then
        promise:next(function(...)
            _refresh_from_background_view(self)
            self._starting_profile_equipped_items = table.clone(self._current_profile_equipped_items)
        end)
    else
        _refresh_from_background_view(self)
    end
end)
