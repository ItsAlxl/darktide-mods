local localization = {
	mod_name = {
		en = "Recolor Stimms",
		["zh-cn"] = "兴奋剂染色",
	},
	mod_description = {
		en = "Customize Stimm colors.",
		["zh-cn"] = "自定义兴奋剂颜色。",
	},
	decal = {
		en = "Sticker",
		["zh-cn"] = "图案",
	},
	red = {
		en = "Red",
		["zh-cn"] = "红色",
	},
	green = {
		en = "Green",
		["zh-cn"] = "绿色",
	},
	blue = {
		en = "Blue",
		["zh-cn"] = "蓝色",
	},
}

local _add_stimm_loc = function(path_to_settings)
	local data = require(path_to_settings)
	localization[data.name] = {
		en = Localize(data.description)
	}
end
_add_stimm_loc("scripts/settings/pickup/pickups/pocketable/syringe_ability_boost_pocketable_pickup")
_add_stimm_loc("scripts/settings/pickup/pickups/pocketable/syringe_corruption_pocketable_pickup")
_add_stimm_loc("scripts/settings/pickup/pickups/pocketable/syringe_power_boost_pocketable_pickup")
_add_stimm_loc("scripts/settings/pickup/pickups/pocketable/syringe_speed_boost_pocketable_pickup")

return localization
