return {
	mod_name = {
		en = "PerilGauge",
		["zh-cn"] = "危机值指示器",
		ru = "Индикатор Угрозы",
	},
	mod_description = {
		en = "Adds a configurable HUD bar for your current peril/heat.",
		["zh-cn"] = "添加一个可配置的 HUD 指示条，用于显示当前危机值/热量。",
		ru = "Peril Gauge - Добавляет в интерфейс настраиваемую полоску текущего уровня угрозы/перегрева.",
	},
	vis_behavior = {
		en = "Visibility Behavior",
		["zh-cn"] = "可见行为",
		ru = "Видимость полосы",
	},
	force_visible = {
		en = "Always Visible",
		["zh-cn"] = "总是显示",
		ru = "Всегда видна",
	},
	force_hidden = {
		en = "Always Hidden",
		["zh-cn"] = "总是隐藏",
		ru = "Всегда спрятана",
	},
	behave_normal = {
		en = "Normal Behavior",
		["zh-cn"] = "正常行为",
		ru = "По умолчанию",
	},
	vanish_delay = {
		en = "Vanish Delay",
		["zh-cn"] = "隐藏延迟",
		ru = "Задержка исчезновения",
	},
	vanish_delay_description = {
		en = "How many seconds pass before the bar vanishes (default 0.0).",
		["zh-cn"] = "指示条隐藏前等待的秒数（默认 0.0）。",
		ru = "Сколько секунд должно пройти, прежде чем полоса исчезнет (по умолчанию 0,0).",
	},
	vanish_speed = {
		en = "Vanish Speed",
		["zh-cn"] = "隐藏速度",
		ru = "Скорость исчезновения",
	},
	vanish_speed_description = {
		en = "How quickly the bar fades out (default 3.0). A value of 1.0 makes it vanish over 1 second. A value of 2.0 makes it vanish over 0.5 seconds. A value of 0.0 causes it to vanish instantly.",
		["zh-cn"] = "指示条隐藏的速度（默认 3.0）。1.0 表示完全隐藏需要 1 秒。2.0 表示完全隐藏需要 0.5 秒。0.0 表示立刻隐藏。",
		ru = "Как быстро исчезает полоса (по умолчанию 3.0). Значение 1.0 заставляет её исчезать в течение 1 секунды. При значении 2,0 она исчезает через полсекунды. Значение 0.0 заставляет её мгновенно исчезать.",
	},
	appear_delay = {
		en = "Appear Delay",
		["zh-cn"] = "显示延迟",
		ru = "Задержка появления",
	},
	appear_delay_description = {
		en = "How many seconds pass before the bar appears (default 0.0).",
		["zh-cn"] = "指示条显示前等待的秒数（默认 0.0）。",
		ru = "Сколько секунд должно пройти до появления полосы (по умолчанию 0,0).",
	},
	appear_speed = {
		en = "Appear Speed",
		["zh-cn"] = "显示速度",
		ru = "Скорость появления",
	},
	appear_speed_description = {
		en = "How quickly the bar fades in (default 3.0). A value of 1.0 makes it appear over 1 second. A value of 2.0 makes it appear over 0.5 seconds. A value of 0.0 causes it to appear instantly.",
		["zh-cn"] = "指示条显示的速度（默认 3.0）。1.0 表示完全显示需要 1 秒。2.0 表示完全显示需要 0.5 秒。0.0 表示立刻显示。",
		ru = "Как быстро появляется полоса (по умолчанию 3.0). Значение 1.0 заставляет её появляться через 1 секунду. При значении 2,0 она появляется через полсекунды. Значение 0.0 заставляет её появляться мгновенно.",
	},
	group_comps = {
		en = "Components",
		["zh-cn"] = "组件",
		ru = "Компоненты",
	},
	comp_bracket = {
		en = "Bar Bracket",
		["zh-cn"] = "指示条边框",
		ru = "Скоба под полосой",
	},
	lbl_text = {
		en = "Label",
		["zh-cn"] = "文字标签",
		ru = "Ярлык",
	},
	lbl_text_none = {
		en = "<Hide Label>",
		["zh-cn"] = "<隐藏标签>",
		ru = "<Скрыть ярлык>",
	},
	lbl_text_peril = {
		en = Utf8.upper(Localize("loc_ranged_warp_charge")),
	},
	lbl_text_skull = {
		en = "",
	},
	lbl_text_flame = {
		en = "",
	},
	comp_orientation = {
		en = "Orientation",
		["zh-cn"] = "方向",
		ru = "Ориентация",
	},
	orientation_horizontal = {
		en = "Horizontal",
		["zh-cn"] = "水平",
		ru = "Горизонтальная",
	},
	orientation_vertical = {
		en = "Vertical",
		["zh-cn"] = "垂直",
		ru = "Вертикальная",
	},
	orientation_horizontal_flipped = {
		en = "Horizontal (Flipped)",
		["zh-cn"] = "水平（翻转）",
		ru = "Горизонтальная (Перевёрнутая)",
	},
	orientation_vertical_flipped = {
		en = "Vertical (Flipped)",
		["zh-cn"] = "垂直（翻转）",
		ru = "Вертикальная (Перевёрнутая)",
	},
	bar_direction = {
		en = "Bar Grow Direction",
		["zh-cn"] = "指示条延伸方向",
		ru = "Направление роста полоски",
	},
	bar_dir_start = {
		en = "Start to End",
		["zh-cn"] = "从头至尾",
		ru = "От начала к концу",
	},
	bar_dir_center = {
		en = "Center to Edges",
		["zh-cn"] = "从中心至两边",
		ru = "От центра к краям",
	},
	bar_dir_end = {
		en = "End to Start",
		["zh-cn"] = "从尾至头",
		ru = "От конца к началу",
	},
	lbl_vert = {
		en = "Label Vertical Position",
		["zh-cn"] = "文字标签垂直位置",
		ru = "Вертикальное положение ярлыка",
	},
	vert_hint = {
		en = "'Middle' is the same as 'Bottom' for horizontal gauges.",
		["zh-cn"] = "对于水平指示器来说，“中心”与“底部”效果相同。",
		ru = "«Посередине» тоже самое, что «Снизу» для горизонтальных индикаторов.",
	},
	vert_top = {
		en = "Top",
		["zh-cn"] = "顶部",
		ru = "Сверху",
	},
	vert_center = {
		en = "Middle",
		["zh-cn"] = "中心",
		ru = "Посередине",
	},
	vert_bottom = {
		en = "Bottom",
		["zh-cn"] = "底部",
		ru = "Снизу",
	},
	lbl_horiz = {
		en = "Label Horizontal Position",
		["zh-cn"] = "文字标签水平位置",
		ru = "Горизонтальное положение ярлыка",
	},
	horiz_hint = {
		en = "'Center' is the same as 'Right' for vertical gauges.",
		["zh-cn"] = "对于垂直指示器来说，“中心”与“右侧”效果相同。",
		ru = "«По центру» тоже самое, что «Справа» для вертикальных индикаторов.",
	},
	horiz_left = {
		en = "Left",
		["zh-cn"] = "左侧",
		ru = "Слева",
	},
	horiz_center = {
		en = "Center",
		["zh-cn"] = "中心",
		ru = "По центру",
	},
	horiz_right = {
		en = "Right",
		["zh-cn"] = "右侧",
		ru = "Справа",
	},
	gauge_thick = {
		en = "Gauge Thickness",
		["zh-cn"] = "指示器厚度",
		ru = "Толщина индикатора",
	},
	gauge_length = {
		en = "Gauge Length",
		["zh-cn"] = "指示器长度",
		ru = "Длина индикатора",
	},
	gauge_alpha = {
		en = "Gauge Opacity",
		["zh-cn"] = "指示器不透明度",
		ru = "Прозрачность датчика",
	},
	show_perc = {
		en = "Show Gauge Percentage",
		["zh-cn"] = "显示指示器百分比",
		ru = "Показывать проценты на индикаторе",
	},
	perc_horiz = {
		en = "Percentage Horizontal Position",
		["zh-cn"] = "百分比水平位置",
		ru = "Горизонтальное положение процентов",
	},
	perc_vert = {
		en = "Percentage Vertical Position",
		["zh-cn"] = "百分比垂直位置",
		ru = "Вертикальное положение процентов",
	},
	perc_num_decimals = {
		en = "Number of Decimal Digits",
		["zh-cn"] = "显示小数位数",
		ru = "Количество десятичных цифр",
	},
	perc_lead_zeroes = {
		en = "Number of Leading 0s",
		["zh-cn"] = "前缀 0 的数量",
	},
	wep_counter_behavior = {
		en = "Special Weapon Gauges",
		["zh-cn"] = "武器特殊状态",
	},
	counter_use_counter = {
		en = "Use weapon gauge",
		["zh-cn"] = "使用武器状态条",
	},
	counter_use_gauge = {
		en = "Use PerilGauge",
		["zh-cn"] = "使用 PerilGauge",
	},
	counter_use_both = {
		en = "Use both",
		["zh-cn"] = "同时使用",
	},
	group_vanilla_text = {
		en = "Base Game Peril Percentage",
	},
	override_color = {
		en = "Override Color",
		["zh-cn"] = "覆盖原版危机值文本颜色",
		ru = "Заменить стандартный цвет текста Угрозы",
	},
	override_alpha = {
		en = "Override Visibility",
		["zh-cn"] = "覆盖原版危机值文本可见度",
		ru = "Заменить стандартную видимость текста Угрозы",
	},
	override_text = {
		en = "Override Text",
		["zh-cn"] = "覆盖原版危机值百分比文本",
		ru = "Заменить стандартный текст процентов Угрозы",
	},
	alpha_mult = {
		en = "Opacity",
	},
}
