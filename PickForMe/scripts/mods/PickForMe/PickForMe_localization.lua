local mod = get_mod("PickForMe")

mod.slot_data = {
	primary = {
		slot = "slot_primary",
		loc = "loc_inventory_title_slot_primary",
		default = true,
	},
	secondary = {
		slot = "slot_secondary",
		loc = "loc_inventory_title_slot_primary",
		default = true,
	},
	curios = {
		slot = "slot_curio",
		filter_slot = "slot_attachment_1",
		loc = "loc_inventory_loadout_group_attachments",
		default = true,
	},
	hat = {
		slot = "slot_gear_head",
		loc = "loc_inventory_title_slot_gear_head",
	},
	shirt = {
		slot = "slot_gear_upperbody",
		loc = "loc_inventory_title_slot_gear_upperbody",
	},
	pants = {
		slot = "slot_gear_lowerbody",
		loc = "loc_inventory_title_slot_gear_lowerbody",
	},
	back = {
		slot = "slot_gear_extra_cosmetic",
		loc = "loc_inventory_title_slot_gear_extra_cosmetic",
	},
	frame = {
		slot = "slot_portrait_frame",
		loc = "loc_inventory_title_slot_portrait_frame",
	},
	insignia = {
		slot = "slot_insignia",
		loc = "loc_inventory_title_slot_insignia",
	},
	pose = {
		slot = "slot_animation_end_of_round",
		loc = "loc_inventory_title_slot_animation_end_of_round",
	},
	dog = {
		slot = "slot_companion_gear_full",
		loc = "loc_inventory_title_slot_companion_gear_full",
	},
}
mod.arg_order = {
	"primary",
	"secondary",
	"weapons",
	"curios",
	"gear",
	"hat",
	"shirt",
	"pants",
	"back",
	"clothes",
	"frame",
	"insignia",
	"portrait",
	"pose",
	"dog",
	"cosmetics",
	"all",
}

local build_arg_list = function(separator, quote, final_separator)
	local list = ""
	local num_args = #mod.arg_order
	for i = 1, num_args - 1 do
		if i > 1 then
			list = list .. separator
		end
		list = list .. quote .. mod.arg_order[i] .. quote
	end

	return list .. final_separator .. quote .. mod.arg_order[num_args] .. quote
end

local localization = {
	mod_description = {
		en = "Easily randomize your current loadout. Try '/pickforme help' in the chat.",
		["zh-cn"] = "快速随机选择配装。试着在聊天框输入 /pickforme help",
	},
	cmd_desc = {
		en = "Randomize your current loadout",
		["zh-cn"] = "随机选择当前配装",
	},
	cmd_help = {
		en = "/pickforme [args...]\nArgs can include " .. build_arg_list(", ", "'", ", or ") .. ". For example, '/pickforme secondary curios' will randomize your secondary weapon and curios. '/pickforme' without arguments is equivalent to the Quick Randomize configured in the mod settings.",
		["zh-cn"] = "/pickforme [参数...]\n参数可以是 " .. build_arg_list(", ", "'", " 或者 ") .. "。例如，'/pickforme secondary curios' 会随机选择副武器和珍品。不带任何参数的 '/pickforme' 命令效果等同于模组选项中设置的快速随机。",
	},
	msg_invalid = {
		en = "Notify on invalid use",
		["zh-cn"] = "用法错误时发送消息",
	},
	wait_a_sec = {
		en = "Please wait a moment before randomizing again",
		["zh-cn"] = "请等待一段时间再重新随机",
	},
	bad_circumstance = {
		en = "You can't use PickForMe during a mission",
		["zh-cn"] = "你不能在任务中随机配装",
	},
	catch_error = {
		en = "Loadout randomization failed",
		["zh-cn"] = "配装随机失败",
	},
	random_character = {
		en = "Start on a random character in character select",
		["zh-cn"] = "在角色选择界面选择随机角色",
	},
	quick_randomize = {
		en = "Quick Randomize",
		["zh-cn"] = "快速随机",
	},
	quick_randomize_keybind = {
		en = "Keybind",
		["zh-cn"] = "快捷键",
	},
}

for key, data in pairs(mod.slot_data) do
	localization[key] = {
		en = Localize(data.loc)
	}
end

return localization
