local mod = get_mod("InventoryStats")

local ConditionalFunctions = require("scripts/settings/buff/validation_functions/conditional_functions")

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
        "weapon_trait_ranged_common_wield_increase_stamina_regen_buff",
        "weapon_trait_melee_common_wield_increase_crit_chance_buff",
        "weapon_trait_increase_crit_chance",
        "weapon_trait_increase_crit_damage",
        "weapon_trait_ranged_increase_crit_chance",
        "weapon_trait_ranged_increase_crit_damage",
        "weapon_trait_ranged_common_wield_increase_crit_chance_buff",
        "weapon_trait_reduce_sprint_cost",
        "weapon_trait_ranged_reduce_sprint_cost",
    }
    for _, buff in pairs(OVERRIDE_WIELD_BUFFS) do
        if templates[buff] and templates[buff].conditional_stat_buffs_func then
            templates[buff].conditional_stat_buffs_func = _override_wield
        else
            mod:warn("Invalid buff %s", buff)
        end
    end
end)

local _calculate_tweak_average = function(tweak, sub_key)
    local sum = 0.0
    local count = 0
    for _, t in pairs(mod.equip_swap.tweaks[tweak]) do
        sum = sum + (t[sub_key] or 0.0)
        count = count + 1
    end
    if count == 0 then
        return 0
    end
    return sum / count
end

local _calculate_tweak_average_sub = function(tweak, sub_key, subsub_key)
    local sum = 0.0
    local count = 0
    for _, t in pairs(mod.equip_swap.tweaks[tweak]) do
        if t[sub_key] then
            sum = sum + (t[sub_key][subsub_key] or 0.0)
            count = count + 1
        end
    end
    if count == 0 then
        return 0
    end
    return sum / count
end

local _create_tweak = function(tweak, sub_keys)
    local final_tweak = {}
    for _, key in pairs(sub_keys) do
        final_tweak[key] = _calculate_tweak_average(tweak, key)
    end
    return final_tweak
end

local _create_tweak_sub = function(tweak, sub_key, subsub_key)
    return { [sub_key] = { [subsub_key] = _calculate_tweak_average_sub(tweak, sub_key, subsub_key) } }
end

mod:hook(CLASS.PlayerUnitWeaponExtension, "weapon_handling_template", function(func, ...)
    if _override_current_weapon_logic() then
        if not mod.equip_swap.override_tweak.weapon_handling then
            mod.equip_swap.override_tweak.weapon_handling = _create_tweak_sub("weapon_handling", "critical_strike", "chance_modifier")
        end
        return mod.equip_swap.override_tweak.weapon_handling
    end
    return func(...)
end)

mod:hook(CLASS.PlayerUnitWeaponExtension, "stamina_template", function(func, ...)
    if _override_current_weapon_logic() then
        if not mod.equip_swap.override_tweak.stamina then
            mod.equip_swap.override_tweak.stamina = _create_tweak("stamina", { "stamina_modifier", "sprint_cost_per_second" })
        end
        return mod.equip_swap.override_tweak.stamina
    end
    return func(...)
end)

mod:hook(CLASS.PlayerUnitWeaponExtension, "sprint_template", function(func, ...)
    if _override_current_weapon_logic() then
        if not mod.equip_swap.override_tweak.sprint then
            mod.equip_swap.override_tweak.sprint = _create_tweak("sprint", { "sprint_speed_mod" })
        end
        return mod.equip_swap.override_tweak.sprint
    end
    return func(...)
end)
