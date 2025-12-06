local _localize_class_action_en = function(class_loc_key, action_loc_key)
	return Localize(class_loc_key) .. " " .. Localize(action_loc_key)
end

return {
	mod_name = {
		en = "AfterBlitz",
		["zh-cn"] = "闪击结束动作",
		ru = "После блица",
	},
	mod_description = {
		en = "Choose what your character does when unequipping their blitz.",
		["zh-cn"] = "设置角色在结束闪击（手雷）之后进行什么操作。",
		ru = "AfterBlitz - Выберите, что будет экипировать ваш персонаж после использования блиц-таланта.",
	},
	after_normal = {
		en = "Default Behavior",
		["zh-cn"] = "默认行为",
		ru = "Стандартное поведение",
	},
	after_keep = {
		en = "Re-Equip Blitz",
		["zh-cn"] = "重新装备闪击",
		ru = "Снова использовать блиц",
	},
	after_previous = {
		en = "Wield Previous Weapon",
		["zh-cn"] = "装备上次的武器",
		ru = "Взять предыдущее оружие",
	},
	after_primary = {
		en = Localize("loc_ingame_wield_1"),
	},
	after_secondary = {
		en = Localize("loc_ingame_wield_2"),
	},
	ag_zealot = {
		en = Localize("loc_class_zealot_title"),
	},
	ag_zealot_quickswap = {
		en = _localize_class_action_en("loc_class_zealot_title", "loc_ingame_quick_wield"),
	},
	ag_veteran = {
		en = Localize("loc_class_veteran_title"),
	},
	ag_veteran_quickswap = {
		en = _localize_class_action_en("loc_class_veteran_title", "loc_ingame_quick_wield"),
	},
	ag_ogryn = {
		en = Localize("loc_class_ogryn_title"),
	},
	ag_ogryn_quickswap = {
		en = _localize_class_action_en("loc_class_ogryn_title", "loc_ingame_quick_wield"),
	},
	ag_psyker_quickswap = {
		en = _localize_class_action_en("loc_class_psyker_title", "loc_ingame_quick_wield"),
	},
	ag_adamant = {
		en = Localize("loc_class_adamant_title"),
	},
	ag_adamant_quickswap = {
		en = _localize_class_action_en("loc_class_adamant_title", "loc_ingame_quick_wield"),
	},
	ag_broker = {
		en = Localize("loc_class_broker_title"),
	},
	ag_broker_quickswap = {
		en = _localize_class_action_en("loc_class_broker_title", "loc_ingame_quick_wield"),
	},
}
