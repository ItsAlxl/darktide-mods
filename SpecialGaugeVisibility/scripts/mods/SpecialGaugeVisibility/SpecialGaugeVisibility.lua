local mod = get_mod("SpecialGaugeVisibility")

local override = {
    kill_charges = true,
    overheat_lockout = true,
}

mod.on_setting_changed = function(id)
    local value = mod:get(id)
    if value == -1 then
        override[id] = nil
    else
        override[id] = value > 0
    end
end

for key, _ in pairs(override) do
    mod.on_setting_changed(key)
end

mod:hook(CLASS.HudElementWeaponCounter, "_weapon_counter_settings", function (func, self, slot_name)
    local settings = func(self, slot_name)
    local unwield_override = settings and override[settings.weapon_counter_type]
    if unwield_override ~= nil then
        settings.show_when_unwielded = unwield_override
    end
    return settings
end)
