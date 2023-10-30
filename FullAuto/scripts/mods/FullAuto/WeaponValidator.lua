local mod = get_mod("FullAuto")

local NORMAL_ACTIONS = { "action_shoot_hip", "action_shoot", "rapid_left", "action_shoot_flame", "action_rapid_left", "action_rapid_right" }
local NORMAL_CHAINS = { "shoot_pressed", "shoot", "shoot_charge" }
local AIMED_ACTIONS = { "action_shoot_zoomed", "action_rapid_zoomed" }
local AIMED_CHAINS = { "zoom_shoot" }

local FULLAUTO_FIREMODE = "full_auto"
local CHARGEUP_TYPE = "charge"

local FALLBACK_DELAY = 0.25

local _get_action = function(template, primary)
    local actions = NORMAL_ACTIONS
    if not primary then
        actions = AIMED_ACTIONS
    end

    for _, a in pairs(actions) do
        local act = template.actions[a]
        if act then
            return act
        end
    end
    return nil
end

local _get_chain_time = function(template, primary)
    local act = _get_action(template, primary)
    if act then
        local chain_actions = NORMAL_CHAINS
        if not primary then
            chain_actions = AIMED_CHAINS
        end

        for _, ca in pairs(chain_actions) do
            local chain = act.allowed_chain_actions[ca]
            if chain then
                return chain.chain_time
            end
        end
        return FALLBACK_DELAY
    end
    return nil
end

local _is_chargeup = function(fm)
    return fm.type == CHARGEUP_TYPE
end

local _check_valid_firemode = function(fm)
    return fm.fire_mode ~= FULLAUTO_FIREMODE and not _is_chargeup(fm)
end

mod.get_weapon_data = function(template, include_psyker_bees)
    if not template or not template.action_inputs then
        return
    end

    local is_bees = template.psyker_smite and include_psyker_bees
    if not is_bees and (not template.displayed_attacks or not template.keywords or not table.contains(template.keywords, "ranged")) then
        return
    end

    local autofire_delay_normal = nil
    local natural_autofire_normal = nil
    local autofire_delay_aim = nil
    local natural_autofire_aim = nil

    if is_bees then
        autofire_delay_normal = _get_chain_time(template, true)
        autofire_delay_aim = _get_chain_time(template, false)
    else
        local primary_attack = template.displayed_attacks.primary
        if primary_attack then
            if _check_valid_firemode(primary_attack) then
                autofire_delay_normal = _get_chain_time(template, true)
            elseif _is_chargeup(primary_attack) then
                natural_autofire_normal = mod.NATURAL_MODE.chargeup
            elseif primary_attack.fire_mode then
                natural_autofire_normal = mod.NATURAL_MODE.fullauto
            end
        end

        local secondary_attack = template.displayed_attacks.secondary
        if secondary_attack and secondary_attack.type == "melee" then
            secondary_attack = template.displayed_attacks.extra
        end
        if secondary_attack then
            if _check_valid_firemode(secondary_attack) then
                autofire_delay_aim = _get_chain_time(template, false)
            elseif _is_chargeup(secondary_attack) then
                natural_autofire_aim = mod.NATURAL_MODE.chargeup
            elseif secondary_attack.fire_mode then
                natural_autofire_aim = mod.NATURAL_MODE.fullauto
            end
        end
    end
    return autofire_delay_normal, autofire_delay_aim, natural_autofire_normal, natural_autofire_aim
end
