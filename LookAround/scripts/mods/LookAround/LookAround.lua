local mod = get_mod("LookAround")

local TAU = 2.0 * math.pi
local PITCH_CLAMP_LOWER = math.pi
local PITCH_CLAMP_UPPER = 0.95 * TAU
local SENSITIVITY_MULT_MOUSE = 0.0025
local SENSITIVITY_MULT_CONTROLLER = 1.2
local CLAMP_OFFSET = 1.7
local INPUT_FILTER = {
    look_raw = true,
    look_controller = true,
    look_controller_lunging = true,
    look_controller_ranged_alternate_fire_improved = true,
    look_controller_ranged_improved = true,
    look_controller_ranged = true,
    look_controller_improved = true,
    look_controller_melee_sticky = true,
    look_controller_melee = true,
}
local freelook_aim = { y = 0.0, p = 0.0 }
local sensitivity_mouse = 1.0
local sensitivity_controller = 1.0

local active_reasons = {}

local auto_on_spectate = false
local clamp_pitch = true

mod.is_requesting_freelook = function()
    for _, r in pairs(active_reasons) do
        if r then
            return true
        end
    end
    return false
end

mod.on_setting_changed = function(id)
    local val = mod:get(id)
    if id == "sensitivity_mouse" then
        sensitivity_mouse = SENSITIVITY_MULT_MOUSE * val
    elseif id == "sensitivity_controller" then
        sensitivity_controller = SENSITIVITY_MULT_CONTROLLER * val
    elseif id == "auto_on_spectate" then
        auto_on_spectate = val
    elseif id == "clamp_pitch" then
        clamp_pitch = val
    end
end
mod.on_setting_changed("sensitivity_mouse")
mod.on_setting_changed("sensitivity_controller")
mod.on_setting_changed("auto_on_spectate")
mod.on_setting_changed("clamp_pitch")

local _set_freelook_origin = function(on_plr_aim)
    if on_plr_aim then
        local plr = Managers.player and Managers.player:local_player(1)
        if plr and plr.player_unit then
            local input_extension = ScriptUnit.extension(plr.player_unit, "input_system")
            freelook_aim.y, freelook_aim.p, _ = input_extension:get_orientation()
            return
        end
    end
    freelook_aim.y = 0.0
    freelook_aim.p = 0.0
end

-- used by the mod "Perspectives"
mod.on_freelook_changed = function(value)
end

local _start_freelook = function(reason, start)
    local was_freelook = mod.is_requesting_freelook()
    if not was_freelook and start then
        _set_freelook_origin(reason == "key")
    end

    if start then
        active_reasons[reason] = true
    else
        active_reasons[reason] = nil
    end

    local now_freelook = mod.is_requesting_freelook()
    if was_freelook ~= now_freelook then
        mod.on_freelook_changed(now_freelook)
    end
end

mod.kb_freelook = function(held)
    if not (Managers.input and Managers.input:cursor_active()) then
        _start_freelook("key", not active_reasons.key)
    end
end

mod:hook_safe(CLASS.CameraHandler, "_switch_follow_target", function(self, new_unit)
    if self._player then
        _start_freelook("spectate", auto_on_spectate and new_unit ~= self._player.player_unit)
    end
end)

mod:hook(CLASS.InputService, "get", function(func, self, action_name)
    local val = func(self, action_name)
    if mod.is_requesting_freelook() and INPUT_FILTER[action_name] then
        if action_name == "look_raw" then
            val.x = val.x * sensitivity_mouse
            val.y = val.y * sensitivity_mouse
        else
            val.x = val.x * sensitivity_controller
            val.y = val.y * sensitivity_controller
        end
        freelook_aim.y = (freelook_aim.y - val.x) % TAU
        freelook_aim.p = (freelook_aim.p - val.y) % TAU
        return Vector3.zero()
    end
    return val
end)

mod:hook(CLASS.CameraManager, "update", function(func, self, dt, t, viewport_name, yaw, pitch, roll)
    if mod.is_requesting_freelook() then
        yaw = freelook_aim.y

        if clamp_pitch then
            freelook_aim.p = math.clamp((freelook_aim.p - CLAMP_OFFSET) % TAU, PITCH_CLAMP_LOWER, PITCH_CLAMP_UPPER) + CLAMP_OFFSET
        end
        pitch = freelook_aim.p
    end
    func(self, dt, t, viewport_name, yaw, pitch, roll)
end)
