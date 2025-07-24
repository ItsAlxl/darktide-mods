return {
	mod_description = {
		en = "Adds keybinds to spam light melee attacks for you.",
		["zh-cn"] = "设置快捷键自动重复近战武器轻攻击。",
		["zh-tw"] = "新增快捷鍵來替你自動重複輕型近戰攻擊。",
	},
	held_keybind = {
		en = "Enable Auto-Swing (Held)",
		["zh-cn"] = "启用自动攻击（按住）",
		["zh-tw"] = "啟用自動揮擊（按住）",
	},
	pressed_keybind = {
		en = "Enable Auto-Swing (Toggle)",
		["zh-cn"] = "启用自动攻击（切换）",
		["zh-tw"] = "啟用自動揮擊（切換）",
	},
	as_modifier = {
		en = "Modifier Mode",
		["zh-cn"] = "修改模式",
		["zh-tw"] = "修飾模式",
	},
	as_modifier_description = {
		en = "If ON, Auto-Swing will modify your normal attack button to spam light attacks instead of performing heavy attacks. If OFF, Auto-Swing will perform light attacks for you without having to press the attack button.",
		["zh-cn"] = "启用时，你的默认攻击键将重复轻攻击而不再重攻击。禁用时，无需按下攻击键，就会执行自动轻攻击。",
		["zh-tw"] = "開啟時，你的一般攻擊按鈕將連續發動輕型攻擊而非重型攻擊。關閉時，自動揮擊將替你執行輕型攻擊，無需按下攻擊按鈕。",
	},
	group_disable_acts = {
		en = "Manual Actions Interrupt Auto-Swing",
		["zh-cn"] = "手动操作打断自动攻击",
		["zh-tw"] = "手動操作中斷自動揮擊",
	},
	persist_after_disable = {
		en = "Temporary Interruption",
		["zh-cn"] = "临时打断",
		["zh-tw"] = "暫時中斷",
	},
	persist_after_disable_description = {
		en = "If ON, Auto-Swing resumes when the interrupting action is finished. If OFF, Auto-Swing is toggled off when an interrupting action starts.",
		["zh-cn"] = "启用时，打断动作结束后恢复自动攻击。禁用时，打断动作开始时关闭自动攻击。",
		["zh-tw"] = "開啟時，中斷動作結束後會恢復自動揮擊。關閉時，中斷動作開始時會關閉自動揮擊。",
	},
	disable_action_one_hold = {
		en = "Attack",
		["zh-cn"] = "攻击",
		["zh-tw"] = "攻擊",
	},
	disable_action_two_hold = {
		en = "Block",
		["zh-cn"] = "格挡",
		["zh-tw"] = "格擋",
	},
	disable_weapon_reload_hold = {
		en = "Reload/Vent",
		["zh-cn"] = "装弹/散热",
		["zh-tw"] = "裝彈/散熱",
	},
	disable_weapon_extra_hold = {
		en = "Weapon Extra",
		["zh-cn"] = "武器特殊",
		["zh-tw"] = "武器特殊功能",
	},
	default_mode = {
		en = "Default to Auto-Swing",
		["zh-cn"] = "默认自动攻击",
		["zh-tw"] = "預設為自動揮擊",
	},
	hud_element = {
		en = "HUD Indicator",
		["zh-cn"] = "HUD 指示器",
		["zh-tw"] = "介面指示器",
	},
	hud_element_size = {
		en = "Indicator Size",
		["zh-cn"] = "指示器大小",
		["zh-tw"] = "指示器大小",
	},
	group_select = {
		en = "Auto-Swinging",
		["zh-cn"] = "自动攻击",
		["zh-tw"] = "自動揮擊",
	},
	group_extra = {
		en = "Misc",
		["zh-cn"] = "杂项",
		["zh-tw"] = "其他設定",
	},
	group_attack_types = {
		en = "Attack Types",
		["zh-cn"] = "攻击类型",
		["zh-tw"] = "攻擊類型",
	},
	include_melee_primary = {
		en = Localize("loc_item_type_weapon_melee") .. " " .. Localize("loc_weapon_action_title_light"),
	},
	include_melee_specials = {
		en = Localize("loc_item_type_weapon_melee") .. " " .. Localize("loc_weapon_action_title_special"),
	},
	include_gauntlets = {
		en = Localize("loc_weapon_pattern_name_ogryn_gauntlet_p1") .. " " .. Localize("loc_weapon_action_title_light"),
	},
	include_ranged_specials = {
		en = Localize("loc_item_type_weapon_ranged") .. " " .. Localize("loc_weapon_special_weapon_bash"),
	},
}
