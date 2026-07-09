local mod = get_mod("TagKeys")

mod.tags = {
	cheer = "loc_communication_wheel_display_name_cheer",
	health = "loc_communication_wheel_display_name_need_health",
	thanks = "loc_communication_wheel_display_name_thanks",
	ammo = "loc_communication_wheel_display_name_need_ammo",
	enemy = "loc_communication_wheel_display_name_enemy",
	location = "loc_communication_wheel_display_name_location",
	attention = "loc_communication_wheel_display_name_attention",
}

local localization = {
	mod_description = {
		en = "Bind individual tagging wheel options to keys.",
		["zh-cn"] = "将单个标签轮盘操作绑定到独立按键上。",
		["zh-tw"] = "將輪盤標記操作綁定到獨立按鍵上。",
	},
}

for id, loc in pairs(mod.tags) do
	localization["key_" .. id] = { en = Localize(loc) }
end

return localization
