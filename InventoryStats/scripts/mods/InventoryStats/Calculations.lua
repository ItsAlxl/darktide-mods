local Stamina = require("scripts/utilities/attack/stamina")
local WeaponTemplate = require("scripts/utilities/weapon/weapon_template")

local EMPTY_TABLE = {}

local _is_wep_ranged = function(wep_template)
    if not wep_template then
        return false
    end
    return WeaponTemplate.is_ranged(wep_template)
end

local _is_wep_melee = function(wep_template)
    if not wep_template then
        return false
    end
    return WeaponTemplate.is_melee(wep_template)
end

return {
    crit_chance = function(plr, plr_unit, wep_template)
        -- taken from scripts/utilities/attack/critical_strike
        local buff_extension = ScriptUnit.extension(plr_unit, "buff_system")
        local buffs = buff_extension:stat_buffs()
        local additional_chance = buffs.critical_strike_chance or 0

        if _is_wep_melee(wep_template) then
            additional_chance = additional_chance + buffs.melee_critical_strike_chance
        elseif _is_wep_ranged(wep_template) then
            additional_chance = additional_chance + buffs.ranged_critical_strike_chance
        end

        local weapon_handling_template = ScriptUnit.has_extension(plr_unit, "weapon_system"):weapon_handling_template() or EMPTY_TABLE
        local critical_strike = weapon_handling_template.critical_strike
        if critical_strike and critical_strike.chance_modifier then
            additional_chance = additional_chance + critical_strike.chance_modifier
        end

        return math.clamp(plr:profile().archetype.base_critical_strike_chance + additional_chance, 0, 1)
    end,

    crit_dmg = function(stat_buffs, wep_template)
        local critical_damage = stat_buffs.critical_strike_damage or 1
        local ranged_critical_damage = _is_wep_ranged(wep_template) and stat_buffs.ranged_critical_strike_damage or 1
        local melee_critical_damage = _is_wep_melee(wep_template) and stat_buffs.melee_critical_strike_damage or 1
        return critical_damage + ranged_critical_damage + melee_critical_damage - 2
    end,

    max_stamina = function(unit, stam_template)
        local _, max = Stamina.current_and_max_value(unit, { current_fraction = 1 }, stam_template)
        return max
    end,

    stamina_regen = function(stam_template, stat_buffs)
        return stam_template.regeneration_per_second * stat_buffs.stamina_regeneration_modifier * stat_buffs.stamina_regeneration_multiplier
    end,

    sprint_speed = function(plr_unit, sprint_template)
        local wep_sprint_template = ScriptUnit.has_extension(plr_unit, "weapon_system"):sprint_template()
        return sprint_template.sprint_move_speed + (wep_sprint_template and wep_sprint_template.sprint_speed_mod or 1)
    end,

    sprint_time = function(plr_unit, stat_buffs, max_stamina)
        local wep_stam_template = ScriptUnit.has_extension(plr_unit, "weapon_system"):stamina_template()
        return max_stamina / ((wep_stam_template and wep_stam_template.sprint_cost_per_second or math.huge) * stat_buffs.sprinting_cost_multiplier)
    end,

    dodge_count = function(plr_unit, stat_buffs)
        local wep_dodge_template = ScriptUnit.has_extension(plr_unit, "weapon_system"):dodge_template()
        return math.ceil((wep_dodge_template and wep_dodge_template.diminishing_return_start or 2) + math.round(stat_buffs.extra_consecutive_dodges or 0))
    end,

    dodge_dist = function(plr_unit, dodge_template)
        local wep_dodge_template = ScriptUnit.has_extension(plr_unit, "weapon_system"):dodge_template()
        return (wep_dodge_template and wep_dodge_template.base_distance or dodge_template.base_distance) * (wep_dodge_template and wep_dodge_template.distance_scale or 1)
    end,

    tough_regen = function(plr_unit, stat_buffs, tough_template, standing_still)
        local wep_tough_template = ScriptUnit.has_extension(plr_unit, "weapon_system"):toughness_template()
        local base_rate = standing_still and tough_template.regeneration_speed.moving or tough_template.regeneration_speed.still
        local weapon_rate_modifier = wep_tough_template and (standing_still and wep_tough_template.regeneration_speed_modifier.moving or wep_tough_template.regeneration_speed_modifier.still) or 1
        local buff_rate_modifier = stat_buffs.toughness_regen_rate_modifier * stat_buffs.toughness_regen_rate_multiplier
        return base_rate * weapon_rate_modifier * buff_rate_modifier
    end,

    tough_regen_delay = function(plr_unit, stat_buffs, tough_template)
        local wep_tough_template = ScriptUnit.has_extension(plr_unit, "weapon_system"):toughness_template()
        local weapon_modifier = wep_tough_template and wep_tough_template.regeneration_delay_modifier or 1
        local toughness_regen_delay_buff_modifier = (stat_buffs.toughness_regen_delay_modifier or 1) * (stat_buffs.toughness_regen_delay_multiplier or 1)
        return tough_template.regeneration_delay * weapon_modifier * toughness_regen_delay_buff_modifier
    end,

    tough_bounty = function(plr_unit, wep_template, stat_buffs, tough_template, max_toughness)
        if not _is_wep_melee(wep_template) then
            return 0.0
        end
        local wep_tough_template = ScriptUnit.has_extension(plr_unit, "weapon_system"):toughness_template()
        local modifier = wep_tough_template and wep_tough_template.recovery_percentage_modifiers.melee_kill or 1
        local toughness_melee_replenish_stat_buff = stat_buffs.toughness_melee_replenish or 1
        local total_toughness_replenish_stat_buff = stat_buffs.toughness_replenish_multiplier
        local stat_buff_multiplier = toughness_melee_replenish_stat_buff + total_toughness_replenish_stat_buff - 1
        return (max_toughness or 1) * tough_template.recovery_percentages.melee_kill * stat_buff_multiplier * modifier
    end
}
