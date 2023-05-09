return {
	mod_name = {
		en = "Inventory Stats",
		ru = "Статистика в инвентаре",
		["zh-cn"] = "装备属性状态",
	},
	mod_description = {
		en = "Displays some stats in the inventory screen",
		["zh-cn"] = "在库存界面显示一些属性状态",
		ru = "Inventory Stats - Отображает некоторую статистику на экране инвентаря",
	},
	visbtn_text = {
		en = "Stats",
		["zh-cn"] = "属性状态",
		ru = "Статистика",
	},
	force_equip = {
		en = "Force Equip Updates",
		["zh-cn"] = "强制装备刷新",
		ru = "Принудительное обновление экипировки",
	},
	force_equip_description = {
		en = "If 'Off', after changing equipment or switching presets, you'll need to exit the inventory menu, wait a couple seconds for your changes to apply, then open the inventory menu again to see the stats change.",
		["zh-cn"] = "如果关闭，则修改装备或切换战具套组时，你需要关闭库存界面，等待几秒装备修改生效，并再次打开库存界面才能看到属性数据变化。",
		ru = "Если «Выключено», то после смены снаряжения или переключения пресетов вам нужно будет выйти из меню инвентаря, подождать пару секунд, пока ваши изменения вступят в силу, затем снова открыть меню инвентаря, чтобы увидеть изменения статистики.",
	},
	use_custom_pages = {
		en = "Use Custom Pages",
		["zh-cn"] = "启用自定义分页",
	},
	use_custom_pages_description = {
		en = "Separates the stats into pages intentionally, as defined in the mod's 'CustomPages.lua' file. By default, it groups similar stats together.",
		["zh-cn"] = "分页显示属性状态，具体属性在“CustomPages.lua”文件中定义。默认分页设置会将有关联的属性分在同一页。",
	},
	page_size = {
		en = "Page Size",
		["zh-cn"] = "分页大小",
	},
	page_size_description = {
		en = "Separates the stats into pages by number. Has no effect if 'Use Custom Pages' is On.",
		["zh-cn"] = "按数量分页属性状态。启用自定义分页时无效。",
	},
	g_stat_toggles = {
		en = "Displayed Stats",
		["zh-cn"] = "显示的属性状态",
		ru = "Отображаемая статистика",
	},
	health = {
		en = "Health",
		["zh-cn"] = "生命值",
		ru = "Здоровье",
	},
	wounds = {
		en = "Wounds",
		["zh-cn"] = "生命格",
		ru = "Раны",
	},
	toughness = {
		en = Localize("loc_hud_display_name_toughness"),
	},
	tough_regen_delay = {
		en = "T. Regen Delay",
		["zh-cn"] = "韧性恢复延迟",
	},
	tough_regen_still = {
		en = "T. Regen (Still)",
		["zh-cn"] = "韧性恢复（静止）",
	},
	tough_regen_moving = {
		en = "T. Regen (Move)",
		["zh-cn"] = "韧性恢复（移动）",
	},
	tough_bounty = {
		en = "T. Regen (Kill)",
		["zh-cn"] = "韧性恢复（击杀）",
	},
	stamina = {
		en = Localize("loc_hud_display_name_stamina"),
	},
	stamina_regen = {
		en = Localize("loc_hud_display_name_stamina") .. " Regen",
		["zh-cn"] = "体力恢复",
		ru = "Реген. выносл.",
	},
	crit_chance = {
		en = "Crit Chance",
		["zh-cn"] = "暴击几率",
		ru = "Шанс крита",
	},
	crit_dmg = {
		en = "Crit Power",
		["zh-cn"] = "暴击伤害倍数",
		ru = "Сила крита",
	},
	sprint_speed = {
		en = Localize("loc_weapon_stats_display_sprint_speed"),
	},
	sprint_time = {
		en = Localize("loc_ingame_sprint") .. " Time",
		["zh-cn"] = "疾跑时间",
		ru = "Время бега",
	},
	dodge_count = {
		en = Localize("loc_weapon_stats_display_effective_dodges"),
		ru = "Макс. уклонений",
	},
	dodge_dist = {
		en = Localize("loc_weapon_stats_display_dodge_distance"),
		ru = "Расст. уклонения",
	},
}
