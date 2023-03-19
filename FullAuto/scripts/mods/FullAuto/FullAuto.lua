local mod = get_mod("FullAuto")

local NORMAL_ACTIONS = { "action_shoot_hip", "action_shoot", "rapid_left" }
local NORMAL_CHAINS = { "shoot_pressed", "shoot", "shoot_charge" }
local AIMED_ACTIONS = { "action_shoot_zoomed" }
local AIMED_CHAINS = { "zoom_shoot" }

local FULLAUTO_FIREMODE = "full_auto"

local track_autofire = false

local autofire_normal_delay = -1
local autofire_aim_delay = -1

local is_firing = false
local test_delay = -1
local last_autofire = -1

local function _disable_autofire()
    track_autofire = false

    autofire_normal_delay = -1
    autofire_aim_delay = -1

    is_firing = false
    test_delay = -1
    last_autofire = -1
end

local function _get_action(template, primary)
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

local function _get_chain_time(template, primary)
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
    end

    return -1
end

local function _check_firemode(fm)
    if fm and fm ~= FULLAUTO_FIREMODE then
        return true
    end
    return false
end

local function _apply_weapon_template(template)
    _disable_autofire()
    if not template or not template.action_inputs then
        return
    end

    --[[
    for t,_ in pairs(template.actions) do
        mod:echo(t)
    end
    mod:echo("%s, %s", template.displayed_attacks.primary.fire_mode, template.displayed_attacks.secondary.fire_mode)
    --]]
    if _check_firemode(template.displayed_attacks.primary.fire_mode) then
        autofire_normal_delay = _get_chain_time(template, true)
    end
    if _check_firemode(template.displayed_attacks.secondary.fire_mode) then
        autofire_aim_delay = _get_chain_time(template, false)
    end

    --mod:echo("normal: %s | aimed: %s", autofire_normal_delay >= 0, autofire_aim_delay >= 0)
    track_autofire = autofire_normal_delay >= 0 or autofire_aim_delay >= 0
    test_delay = autofire_normal_delay
end

mod:hook_safe("PlayerUnitWeaponExtension", "on_slot_wielded", function(self, slot_name, ...)
    if slot_name == "slot_secondary" then
        _apply_weapon_template(self._weapons[slot_name].weapon_template)
    else
        _disable_autofire()
    end
end)

mod:hook("InputService", "get", function(func, self, action_name)
    local val = func(self, action_name)
    if track_autofire then
        if val then
            if action_name == "action_one_pressed" then
                is_firing = true
                last_autofire = -1
            end
            if action_name == "action_one_release" then
                is_firing = false
            end

            if action_name == "action_two_pressed" then
                if autofire_aim_delay >= 0 then
                    test_delay = autofire_aim_delay
                else
                    test_delay = -1
                end
            end
            if action_name == "action_two_release" then
                if autofire_normal_delay >= 0 then
                    test_delay = autofire_normal_delay
                else
                    test_delay = -1
                end
            end
        end

        if is_firing and action_name == "action_one_pressed" then
            if test_delay >= 0 then
                local this_t = Managers.time and Managers.time:time("main")
                if last_autofire < 0 or this_t - last_autofire >= test_delay then
                    last_autofire = this_t
                    return true
                end
                return false
            end
        end
    end

    return val
end)
