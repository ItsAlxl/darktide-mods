local mod = get_mod("InventoryStats")
mod.stat_order = {
	"wounds",
	"health",
	"toughness",
	"tough_regen_delay",
	"tough_regen_still",
	"tough_regen_moving",
	"tough_bounty",
	"crit_chance",
	"crit_dmg",
	"dodge_count",
	"dodge_dist",
	"stamina",
	"stamina_regen",
	"sprint_speed",
	"sprint_time",
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
	name = mod:localize("mod_name"),
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
				setting_id    = "use_custom_pages",
				type          = "checkbox",
				default_value = true,
			},
			{
				setting_id    = "page_size",
				type          = "numeric",
				default_value = 12,
				range         = { 1, 12 },
			},
			{
				setting_id  = "g_stat_toggles",
				type        = "group",
				sub_widgets = stat_toggles
			},
		}
	}
}
