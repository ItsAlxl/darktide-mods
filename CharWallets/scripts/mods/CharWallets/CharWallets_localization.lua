return {
	mod_name = {
		en = "CharWallets",
		ru = "Кошельки персонажей",
		["zh-cn"] = "角色钱包",
	},
	mod_description = {
		en = "Display your characters' wallets on the character selection screen.",
		["zh-cn"] = "在特工选择界面显示角色的材料数量。",
		ru = "Char Wallets - Отображение вашей валюты на экране выбора персонажей.",
	},
	options_vis = {
		en = "Wallet Contents",
		["zh-cn"] = "材料内容",
		ru = "Отображаемая валюта",
	},
	options_order = {
		en = "Wallet Order",
		["zh-cn"] = "材料顺序",
		ru = "Порядок отображения",
	},
	currency_credits = {
		en = Localize("loc_currency_name_credits")
	},
	currency_marks = {
		-- Trim because the en localized string has
		-- a space at the beginning and I hate it
		en = string.trim(Localize("loc_currency_name_marks"))
	},
	currency_plasteel = {
		en = Localize("loc_currency_name_plasteel")
	},
	currency_diamantine = {
		en = Localize("loc_currency_name_diamantine")
	},
	currency_contracts = {
		en = Localize("loc_contracts_list_title")
	},
	options_spacing = {
		en = "Spacing",
		["zh-cn"] = "界面布局",
		ru = "Размещение",
	},
	start_x = {
		en = "Wallet Offset",
		["zh-cn"] = "材料数偏移量",
		ru = "Смещение валют",
	},
	size_x = {
		en = "Wallet Stretch",
		["zh-cn"] = "材料数拉伸量",
		ru = "Растяжение по горизонтали",
	},
	contracts_x = {
		en = "Contracts Offset",
		["zh-cn"] = "每周协议偏移量",
		ru = "Смещение контрактов",
	},
	limit_digits = {
		en = "Shorten Large Numbers",
		["zh-cn"] = "缩写大数字",
		ru = "Сокращать большие числа",
	},
	shortened_thousand = {
		en = "k",
		ru = "т",
	},
	shortened_million = {
		en = "M",
		ru = "м",
	},
	shortened_billion = {
		en = "B",
		ru = "мд",
	},
}
