local mod = get_mod("InventoryStats")

local ConditionalFunctions = require("scripts/settings/buff/helper_functions/conditional_functions")
local Weapon = require("scripts/extension_systems/weapon/weapon")
local WeaponTemplate = require("scripts/utilities/weapon/weapon_template")

local _override_current_weapon_logic = function()
    return Managers.ui and Managers.ui:view_active("inventory_view") and mod.equip_swap.wep
end

local _override_wield = function(template_data, template_context)
    if _override_current_weapon_logic() then
        return table.contains(mod.equip_swap.wep.__master_item.slots, template_context.item_slot_name)
    end
    return ConditionalFunctions.is_item_slot_wielded(template_data, template_context)
end

mod:hook_require("scripts/settings/buff/buff_templates", function(templates)
    -- here's how I search for these:
    -- regex: sprint[^\n]+= \{
    -- include: *settings/buff/*weapon_traits*
    local OVERRIDE_WIELD_BUFFS = {
        "weapon_trait_increase_stamina",
        "weapon_trait_ranged_increase_stamina",
        "weapon_trait_increase_crit_chance",
        "weapon_trait_increase_crit_damage",
        "weapon_trait_ranged_increase_crit_chance",
        "weapon_trait_ranged_increase_crit_damage",
        "weapon_trait_reduce_sprint_cost",
    }
    for _, buff in pairs(OVERRIDE_WIELD_BUFFS) do
        if templates[buff] and templates[buff].conditional_stat_buffs_func then
            templates[buff].conditional_stat_buffs_func = _override_wield
        else
            mod:warning("Invalid buff %s", buff)
        end
    end
end)

local function _scrub_subtweak(subtweak, report_par, skip)
    for key, val in pairs(subtweak) do
        local t = type(val)
        if t == "table" then
            if skip then
                _scrub_subtweak(val, report_par)
            else
                report_par[key] = {}
                _scrub_subtweak(val, report_par[key])
            end
        elseif t == "number" then
            if not report_par[key] then
                report_par[key] = {
                    invstat_t = t,
                    sum = 0,
                    count = 0
                }
            end
            report_par[key].sum = report_par[key].sum + val
            report_par[key].count = report_par[key].count + 1
        elseif t == "string" then
            if not report_par[key] then
                report_par[key] = {
                    invstat_t = t,
                    sample = {}
                }
            end
            if report_par[key].sample[val] then
                report_par[key].sample[val] = report_par[key].sample[val] + 1
            else
                report_par[key].sample[val] = 1
            end
        end
    end
end

local function finalize_tweak_report(report)
    local final_tweak = {}
    for key, val in pairs(report) do
        if type(val) == "table" then
            if val.invstat_t then
                if val.invstat_t == "number" then
                    if val.count > 0 then
                        final_tweak[key] = val.sum / val.count
                    end
                elseif val.invstat_t == "string" then
                    local highest_count = 0
                    local highest_str = ""
                    for str, count in pairs(val.sample) do
                        if count > highest_count then
                            highest_str = str
                            highest_count = count
                        end
                    end
                    final_tweak[key] = highest_str
                end
            else
                final_tweak[key] = finalize_tweak_report(val)
            end
        else
            final_tweak[key] = val
        end
    end
    return final_tweak
end

local _create_tweak_exhaustive = function(tweak)
    local report = {}
    for key, sub in pairs(tweak) do
        report[key] = {}
        _scrub_subtweak(sub, report[key], true)
    end
    return finalize_tweak_report(report)
end

mod.set_equipped_wep = function(w)
    if w == mod.equip_swap.wep then
        return
    end

    if w then
        mod.equip_swap.template = WeaponTemplate.weapon_template_from_item(w)
        mod.equip_swap.tweaks, _, _, _ = Weapon._init_traits(nil, mod.equip_swap.template, w, nil, nil)
        mod.equip_swap.wep = w
        mod.equip_swap.override_tweak = _create_tweak_exhaustive(mod.equip_swap.tweaks)
    else
        mod.equip_swap.template = nil
        mod.equip_swap.tweaks = nil
        mod.equip_swap.wep = nil
        mod.equip_swap.override_tweak = nil
    end
    mod.update_inventory_stats()
end

local _replace_template_getter = function(template_key, func, ...)
    if _override_current_weapon_logic() and mod.equip_swap.override_tweak[template_key] then
        return mod.equip_swap.override_tweak[template_key]
    end
    return func(...)
end

mod:hook(CLASS.PlayerUnitWeaponExtension, "weapon_handling_template", function(func, ...)
    return _replace_template_getter("weapon_handling", func, ...)
end)

mod:hook(CLASS.PlayerUnitWeaponExtension, "stamina_template", function(func, ...)
    return _replace_template_getter("stamina", func, ...)
end)

mod:hook(CLASS.PlayerUnitWeaponExtension, "sprint_template", function(func, ...)
    return _replace_template_getter("sprint", func, ...)
end)

mod:hook(CLASS.PlayerUnitWeaponExtension, "dodge_template", function(func, ...)
    return _replace_template_getter("dodge", func, ...)
end)

mod:hook(CLASS.PlayerUnitWeaponExtension, "toughness_template", function(func, ...)
    return _replace_template_getter("toughness", func, ...)
end)
