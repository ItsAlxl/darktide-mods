local mod = get_mod("IgnorePsykerGrenades")

local ignores = {
    psyker_throwing_knives = mod:get("psyker_throwing_knives"),
    psyker_smite = mod:get("psyker_smite"),
    psyker_chain_lightning = mod:get("psyker_chain_lightning")
}

mod.on_setting_changed = function(id)
	ignores[id] = mod:get(id)
end

local _should_ignore = function(ability)
    return ability and ability.name and ignores[ability.name]
end

mod:hook(CLASS.HudElementTeamPlayerPanel, "_get_weapon_throwables_status", function(func, self, ability_extension)
    local equipped_abilities = ability_extension and ability_extension:equipped_abilities()
    if equipped_abilities and _should_ignore(equipped_abilities.grenade_ability) then
        return 3
    end
    return func(self, ability_extension)
end)
