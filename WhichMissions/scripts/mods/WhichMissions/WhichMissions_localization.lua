return {
	mod_description = {
		en = "Provides some commands to help you figure out which missions you're missing for penances. Try /wm_help in the chat.",
		["zh-cn"] = "提供一些命令，查看你的任务苦修还缺少哪些任务类型。在聊天中输入 /wm_help 获取帮助。",
	},
	mod_help = {
		en = "Note: all command arguments must be provided in lowercase. Alternatively, difficulty can be provided as a number (1-5). To skip an optional argument, use * (eg /wm_class * psyker).\n\n/wm_account [difficulty]\nLists which mission types you need for a given difficulty for the account-wide penances. If no difficulty is provided, it defaults to the lowest difficulty you haven't finished.\n\n/wm_class [difficulty] [class]\nLists which mission types you need for a given difficulty and class. If no class is provided, it defaults to your current class. If no difficulty is provided, it defaults to the lowest difficulty you haven't finished.",
		["zh-cn"] = "注意：所有命令参数必须为小写。难度参数也可以为数字（1-5）。要跳过可选参数，使用星号 * 代替\n（例如 /wm_class * psyker）。\n可用难度：sedition, uprising, malice, heresy, damnation\n可用职业：veteran, zealot, ogryn, psyker\n\n/wm_account [难度]\n列出指定难度的全职业任务苦修还缺少哪些任务类型。如果未提供难度，默认为当前尚未完成的最低难度。\n\n/wm_class [难度] [职业]\n列出指定难度的分职业任务苦修还缺少哪些任务类型。如果未提供职业，默认为当前职业。如果未提供难度，默认为当前尚未完成的最低难度。",
	},
	cmd_desc_help = {
		en = "Explains how to use WhichMissions",
		["zh-cn"] = "解释 WhichMissions 模组使用方法",
	},
	cmd_desc_class = {
		en = "WhichMissions you need for a difficulty & class",
		["zh-cn"] = "查看指定难度的分职业任务苦修状态",
	},
	cmd_desc_account = {
		en = "WhichMissions you need for a difficulty",
		["zh-cn"] = "查看指定难度的全职业任务苦修状态",
	},
	error_fetch_failed = {
		en = "Achievement data fetch failed",
	},
	account_needs = {
		en = "Your account needs %s more on %s:\n%s",
		["zh-cn"] = "你还需要做%s类任务达成%s的全职业任务苦修：\n%s",
	},
	account_finished = {
		en = "Congratulations! You have finished the account-wide penance for %s.",
		["zh-cn"] = "恭喜！你已经完成了%s的全职业任务苦修。",
	},
	class_needs = {
		en = "Your %s needs %s more on %s:\n%s",
		["zh-cn"] = "你的%s还需要做%s类任务达成%s的任务苦修：\n%s",
	},
	class_finished = {
		en = "Congratulations! Your %s has finished the penance for %s.",
		["zh-cn"] = "恭喜！你的%s已经完成了%s的任务苦修。",
	},
	difficulty_class_any = {
		en = "any difficulty",
		["zh-cn"] = "任意难度",
	},
}
