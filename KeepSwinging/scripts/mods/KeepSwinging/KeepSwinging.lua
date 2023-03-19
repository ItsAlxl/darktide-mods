local mod = get_mod("KeepSwinging")

local SWING_DELAY_FRAMES = 5

local allow_autoswing = false
local is_swinging = false
local swing_delay = 0

local function _allow_autoswing(a)
    allow_autoswing = a
    is_swinging = false
end

mod:hook_safe("PlayerUnitWeaponExtension", "on_slot_wielded", function(self, slot_name, ...)
    _allow_autoswing(slot_name == "slot_primary")
end)

mod:hook("InputService", "get", function(func, self, action_name)
    local val = func(self, action_name)
    if allow_autoswing then
        if is_swinging and action_name == "action_one_hold" and not val then
            swing_delay = swing_delay - 1
            if swing_delay <= 0 then
                swing_delay = SWING_DELAY_FRAMES
                return true
            end
            return false
        end
    end

    return val
end)

mod._toggle_swinging = function(held)
    is_swinging = not is_swinging
    if is_swinging then
        swing_delay = 0
    end
end
