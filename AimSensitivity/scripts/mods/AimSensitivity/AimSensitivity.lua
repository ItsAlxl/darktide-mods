local mod = get_mod("AimSensitivity")

local aim_sensitivity_mult = mod:get("aim_sensitivity_mult")
mod.on_setting_changed = function(id)
    if id == "aim_sensitivity_mult" then
        aim_sensitivity_mult = mod:get(id)
    end
end

mod:hook(CLASS.PlayerUnitWeaponExtension, "sensitivity_modifier", function(func, self)
    if self._alternate_fire_read_component.is_active then
        return func(self) * aim_sensitivity_mult
    end
    return func(self)
end)
