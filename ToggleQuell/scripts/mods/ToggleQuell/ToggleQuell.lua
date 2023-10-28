local mod = get_mod("ToggleQuell")

local keep_quelling = false
local next_hold_cancels = false

local toggle_threshold = nil
local threshold_t = nil

local untoggle_actions = {
    action_one_pressed = mod:get("action_one_pressed"),
    action_two_pressed = mod:get("action_two_pressed"),
    weapon_extra_pressed = mod:get("weapon_extra_pressed"),
}

mod.on_setting_changed = function(id)
    local val = mod:get(id)
    if id == "toggle_timing" then
        if val < 0.05 then
            toggle_threshold = nil
        else
            toggle_threshold = val
        end
    elseif untoggle_actions[id] ~= nil then
        untoggle_actions[id] = val
    end
end
mod.on_setting_changed("toggle_timing")

local _get_player = function()
    return Managers.player:local_player(1)
end

local _get_now_t = function()
    return Managers.time:time("main")
end

mod:hook_safe(CLASS.ActionVentWarpCharge, "start", function(self, ...)
    if self._player == _get_player() then
        keep_quelling = true
        next_hold_cancels = false
        threshold_t = toggle_threshold and (toggle_threshold + _get_now_t())
    end
end)

mod:hook_safe(CLASS.ActionVentWarpCharge, "finish", function(self, ...)
    if self._player == _get_player() then
        keep_quelling = false
    end
end)

local _input_action_hook = function(func, self, action_name)
    local val = func(self, action_name)
    if keep_quelling then
        if action_name == "weapon_reload_hold" then
            if val then
                if next_hold_cancels then
                    keep_quelling = false
                end
            elseif not next_hold_cancels then
                if threshold_t and _get_now_t() > threshold_t then
                    keep_quelling = false
                else
                    next_hold_cancels = true
                end
            end
            return true
        end
        if untoggle_actions[action_name] and val then
            keep_quelling = false
        end
    end
    return val
end
mod:hook(CLASS.InputService, "_get", _input_action_hook)
mod:hook(CLASS.InputService, "_get_simulate", _input_action_hook)
