local mod = get_mod("AfterGrenade")

local dropdown_options = {
	{ text = "after_normal",    value = "" },
	{ text = "after_keep",      value = "grenade_ability_pressed" },
	{ text = "after_previous",  value = "PREVIOUS" },
	{ text = "after_primary",   value = "wield_1" },
	{ text = "after_secondary", value = "wield_2" },
}

local create_ag_dropdown = function(id, default)
	return {
		setting_id    = id,
		type          = "dropdown",
		default_value = default,
		options       = table.clone(dropdown_options),
	}
end

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			create_ag_dropdown("ag_zealot", "wield_1"),
			create_ag_dropdown("ag_zealot_quickswap", "PREVIOUS"),
			create_ag_dropdown("ag_veteran", "grenade_ability_pressed"),
			create_ag_dropdown("ag_veteran_quickswap", "PREVIOUS"),
			create_ag_dropdown("ag_ogryn", "PREVIOUS"),
			create_ag_dropdown("ag_ogryn_quickswap", "PREVIOUS"),
			create_ag_dropdown("ag_psyker_quickswap", "PREVIOUS"),
			create_ag_dropdown("ag_adamant", "grenade_ability_pressed"),
			create_ag_dropdown("ag_adamant_quickswap", "PREVIOUS"),
		}
	}
}
