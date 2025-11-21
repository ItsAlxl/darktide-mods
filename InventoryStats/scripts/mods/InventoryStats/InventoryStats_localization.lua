return {
	mod_name = {
		en = "Inventory Stats",
		ru = "Статистика в инвентаре",
		["zh-cn"] = "装备属性状态",
		["zh-tw"] = "裝備屬性統計",
	},
	mod_description = {
		en = "Displays some stats in the inventory screen",
		["zh-cn"] = "在库存界面显示一些属性状态",
		ru = "Inventory Stats - Отображает некоторую статистику на экране инвентаря",
		["zh-tw"] = "在庫存介面顯示各種屬性統計",
	},
	visbtn_text = {
		en = "Stats",
		["zh-cn"] = "属性状态",
		ru = "Статистика",
		["zh-tw"] = "屬性統計",
	},
	force_equip = {
		en = "Force Equip Updates",
		["zh-cn"] = "强制装备刷新",
		ru = "Принудительное обновление экипировки",
		["zh-tw"] = "強制裝備更新",
	},
	force_equip_description = {
		en = "If 'Off', after changing equipment or switching presets, you'll need to exit the inventory menu, wait a couple seconds for your changes to apply, then open the inventory menu again to see the stats change.",
		["zh-cn"] = "如果关闭，则修改装备或切换战具套组时，你需要关闭库存界面，等待几秒装备修改生效，并再次打开库存界面才能看到属性数据变化。",
		ru = "Если «Выключено», то после смены снаряжения или переключения пресетов вам нужно будет выйти из меню инвентаря, подождать пару секунд, пока ваши изменения вступят в силу, затем снова открыть меню инвентаря, чтобы увидеть изменения статистики.",
		["zh-tw"] = "若為「關閉」，當更換裝備或切換預設配置後，你需要退出庫存選單，等待數秒讓變更生效，然後重新開啟庫存選單才能看到屬性數據變化。",
	},
	use_custom_pages = {
		en = "Use Custom Pages",
		["zh-cn"] = "启用自定义分页",
		["zh-tw"] = "使用自訂頁面",
	},
	use_custom_pages_description = {
		en = "Separates the stats into pages intentionally, as defined in the mod's 'CustomPages.lua' file. By default, it groups similar stats together.",
		["zh-cn"] = "分页显示属性状态，具体属性在“CustomPages.lua”文件中定义。默认分页设置会将有关联的属性分在同一页。",
		["zh-tw"] = "按照模組中「CustomPages.lua」檔案的定義將屬性統計分頁顯示。預設設定會將相關屬性歸類在同一頁。",
	},
	page_size = {
		en = "Page Size",
		["zh-cn"] = "分页大小",
		["zh-tw"] = "頁面大小",
	},
	page_size_description = {
		en = "Separates the stats into pages by number. Has no effect if 'Use Custom Pages' is On.",
		["zh-cn"] = "按数量分页属性状态。启用自定义分页时无效。",
		["zh-tw"] = "根據數量將屬性統計分頁。若啟用「使用自訂頁面」則此設定無效。",
	},
	g_stat_toggles = {
		en = "Displayed Stats",
		["zh-cn"] = "显示的属性状态",
		ru = "Отображаемая статистика",
		["zh-tw"] = "顯示的屬性統計",
	},
	health = {
		en = "Health",
		["zh-cn"] = "生命值",
		ru = "Здоровье",
		["zh-tw"] = "生命值",
	},
	wounds = {
		en = "Wounds",
		["zh-cn"] = "生命格",
		ru = "Раны",
		["zh-tw"] = "生命格",
	},
	toughness = {
		en = Localize("loc_hud_display_name_toughness"),
	},
	tough_regen_delay = {
		en = "T. Regen Delay",
		["zh-cn"] = "韧性恢复延迟",
		["zh-tw"] = "韌性恢復延遲",
	},
	tough_regen_still = {
		en = "T. Regen (Still)",
		["zh-cn"] = "韧性恢复（静止）",
		["zh-tw"] = "韌性恢復（靜止）",
	},
	tough_regen_moving = {
		en = "T. Regen (Move)",
		["zh-cn"] = "韧性恢复（移动）",
		["zh-tw"] = "韌性恢復（移動）",
	},
	tough_bounty = {
		en = "T. Regen (Kill)",
		["zh-cn"] = "韧性恢复（击杀）",
		["zh-tw"] = "韌性恢復（擊殺）",
	},
	stamina = {
		en = Localize("loc_hud_display_name_stamina"),
	},
	stamina_regen = {
		en = Localize("loc_hud_display_name_stamina") .. " Regen",
		["zh-cn"] = "体力恢复",
		ru = "Реген. выносл.",
		["zh-tw"] = "體力恢復",
	},
	crit_chance = {
		en = "Crit Chance",
		["zh-cn"] = "暴击几率",
		ru = "Шанс крита",
		["zh-tw"] = "暴擊機率",
	},
	crit_dmg = {
		en = "Crit Power",
		["zh-cn"] = "暴击伤害倍数",
		ru = "Сила крита",
		["zh-tw"] = "暴擊傷害倍率",
	},
	sprint_speed = {
		en = Localize("loc_weapon_stats_display_sprint_speed"),
		["zh-tw"] = "衝刺速度",
	},
	sprint_time = {
		en = Localize("loc_ingame_sprint") .. " Time",
		["zh-cn"] = "疾跑时间",
		ru = "Время бега",
		["zh-tw"] = "衝刺時間",
	},
	dodge_count = {
		en = Localize("loc_weapon_stats_display_effective_dodges"),
		ru = "Макс. уклонений",
		["zh-tw"] = "有效閃避次數",
	},
	dodge_dist = {
		en = Localize("loc_weapon_stats_display_dodge_distance"),
		ru = "Расст. уклонения",
		["zh-tw"] = "閃避距離",
	},
}
