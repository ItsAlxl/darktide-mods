local mod = get_mod("InventoryStats")
mod.stat_order = {
	"health",
	"toughness",
	"wounds",
	"crit_chance",
	"crit_dmg",
	"stamina",
	"stamina_regen",
	"sprint_speed",
	"sprint_time",
	"dodge_count",
	"dodge_dist",
}

local stat_toggles = {}
for _, stat in pairs(mod.stat_order) do
	stat_toggles[#stat_toggles + 1] = {
		setting_id    = stat,
		type          = "checkbox",
		default_value = true,
	}
end

return {
	name = "InventoryStats",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id    = "force_equip",
				type          = "checkbox",
				default_value = true,
			},
			{
				setting_id  = "g_stat_toggles",
				type        = "group",
				sub_widgets = stat_toggles
			},
		}
	}
}
