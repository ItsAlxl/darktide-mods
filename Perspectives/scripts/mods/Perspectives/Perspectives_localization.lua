local mod = get_mod("Perspectives")

local loc = {
	mod_description = {
		en = "Switch between first and third person perspectives.",
		["zh-cn"] = "在第一人称和第三人称视角之间切换。",
	},
	allow_switching = {
		en = "Allow Perspective Switching",
		["zh-cn"] = "允许视角切换",
	},
	allow_switching_description = {
		en = "Turn off to effectively disable the mod.",
		["zh-cn"] = "关闭此选项实际禁用此模组。",
	},
	third_person_toggle = {
		en = "Switch Perspective (Toggle)",
		["zh-cn"] = "切换视角（切换）",
	},
	third_person_held = {
		en = "Switch Perspective (Held)",
		["zh-cn"] = "切换视角（按住）",
	},
	cycle_shoulder = {
		en = "Cycle Viewpoint",
		["zh-cn"] = "循环视角",
	},
	aim_mode = {
		en = "Aiming Behavior",
		["zh-cn"] = "瞄准行为",
	},
	nonaim_mode = {
		en = "Non-Aiming Behavior",
		["zh-cn"] = "非瞄准行为",
	},
	viewpoint_1p = {
		en = "Switch to 1st Person",
		["zh-cn"] = "切换到第一人称",
	},
	viewpoint_cycle = {
		en = "Cycled Viewpoint",
		["zh-cn"] = "循环视角",
	},
	viewpoint_center = {
		en = "Center",
		["zh-cn"] = "中心",
	},
	viewpoint_right = {
		en = "Right",
		["zh-cn"] = "右侧",
	},
	viewpoint_left = {
		en = "Left",
		["zh-cn"] = "左侧",
	},
	cycle_includes_center = {
		en = "Include Center in Cycle",
		["zh-cn"] = "在循环中包含中心视角",
	},
	center_to_1p_human = {
		en = "Center Aim Goes to 1st Person (Human)",
		["zh-cn"] = "中心瞄准改为第一人称（人类）",
	},
	center_to_1p_ogryn = {
		en = "Center Aim Goes to 1st Person (Ogryn)",
		["zh-cn"] = "中心瞄准改为第一人称（欧格林）",
	},
	center_to_1p_description = {
		en = "If on, when cycled to a centered viewpoint and aiming, you'll temporarily go to 1st person instead of using the 3rd person centered aim camera. This is recommended for humans, and very strongly recommended for Ogryns.",
		["zh-cn"] = "启用后，切换到中心视角并在瞄准时，你会临时进入第一人称而不是第三人称中心视角。推荐为人类角色启用，强烈推荐为欧格林启用。",
	},
	perspective_transition_time = {
		en = "Perspective Transition Time",
		["zh-cn"] = "视角切换时间",
	},
	group_custom_viewpoint = {
		en = "Custom Viewpoint",
		["zh-cn"] = "自定义视角",
	},
	custom_distance = {
		en = "Camera Distance (Non-Aiming)",
		["zh-cn"] = "摄像机距离（非瞄准）",
	},
	custom_distance_description = {
		en = "Increase to push your camera farther backward.",
		["zh-cn"] = "增大表示向后移动摄像机。",
	},
	custom_offset = {
		en = "Camera Offset (Non-Aiming)",
		["zh-cn"] = "摄像机偏移（非瞄准）",
	},
	custom_offset_description = {
		en = "Increase to push your camera farther from the center of your character. For example, the left-side viewpoint will be farther left at higher values.",
		["zh-cn"] = "增大表示摄像机远离角色中心。例如，值越大，左侧视角就更偏左。",
	},
	custom_distance_zoom = {
		en = "Camera Distance (Aiming)",
		["zh-cn"] = "摄像机距离（瞄准）",
	},
	custom_offset_zoom = {
		en = "Camera Offset (Aiming)",
		["zh-cn"] = "摄像机偏移（瞄准）",
	},
	custom_distance_ogryn = {
		en = "Camera Distance (Ogryn)",
		["zh-cn"] = "摄像机距离（欧格林）",
	},
	custom_offset_ogryn = {
		en = "Camera Offset (Ogryn)",
		["zh-cn"] = "摄像机偏移（欧格林）",
	},
	xhair_fallback = {
		en = "'No Crosshair' in 3rd Person",
		["zh-cn"] = "第三人称下的“无准星时”设置",
	},
	use_lookaround_node = {
		en = "[LookAround] 3rd Person Inspect",
		["zh-cn"] = "[LookAround] 第三人称检视",
	},
	use_lookaround_node_description = {
		en = "When using the mod LookAround to get freelook in 3rd person, use the 3rd Person Inspect viewpoint.",
		["zh-cn"] = "在第三人称下使用 LookAround 模组的自由查看时，使用第三人称检视视角。",
	},
	default_perspective_mode = {
		en = "Initial Perspective",
		["zh-cn"] = "初始视角",
	},
	defper_normal = {
		en = "Default",
		["zh-cn"] = "默认",
	},
	defper_swapped = {
		en = "Opposite of Default",
		["zh-cn"] = "反转默认",
	},
	defper_always_first = {
		en = "1st Person",
		["zh-cn"] = "第一人称",
	},
	defper_always_third = {
		en = "3rd Person",
		["zh-cn"] = "第三人称",
	},
	group_3p_behavior = {
		en = "3rd Person Behavior",
		["zh-cn"] = "第三人称行为",
	},
	group_autoswitch = {
		en = "Auto-switch Perspectives",
		["zh-cn"] = "自动切换视角",
	},
	autoswitch_spectate = {
		en = "Spectating",
		["zh-cn"] = "旁观者",
	},
	autoswitch_slot_primary = {
		en = Localize("loc_ingame_wield_1")
	},
	autoswitch_slot_secondary = {
		en = Localize("loc_ingame_wield_2")
	},
	autoswitch_slot_grenade_ability = {
		en = Localize("loc_ingame_grenade_ability")
	},
	autoswitch_slot_pocketable = {
		en = Localize("loc_ingame_wield_3_v2")
	},
	autoswitch_slot_pocketable_small = {
		en = Localize("loc_ingame_wield_4_v2")
	},
	autoswitch_slot_device = {
		en = Localize("loc_ingame_wield_5")
	},
	autoswitch_slot_luggable = {
		en = Localize("loc_item_type_luggable")
	},
	autoswitch_slot_luggable_description = {
		en = Localize("loc_pickup_luggable_battery_01") .. " / " .. Localize("loc_pickup_luggable_control_rod_01")
	},
	autoswitch_slot_unarmed = {
		en = "Unarmed",
		["zh-cn"] = "无装备",
	},
	autoswitch_slot_unarmed_description = {
		en = "Occurs whenever your character puts your weapon away, e.g. when interacting with certain objects or being kocked back.",
		["zh-cn"] = "角色收起武器时出现，例如与特定对象交互或者被击退的情况。",
	},
	autoswitch_sprint = {
		en = Localize("loc_ingame_sprint")
	},
	autoswitch_lunge_ogryn = {
		en = "Charge (Ogryn)",
		["zh-cn"] = "冲锋（欧格林）",
	},
	autoswitch_lunge_human = {
		en = "Charge (Zealot)",
		["zh-cn"] = "冲锋（狂信徒）",
	},
	autoswitch_act2_primary = {
		en = Localize("loc_ingame_action_two") .. " - " .. Localize("loc_inventory_title_slot_primary")
	},
	autoswitch_act2_secondary = {
		en = Localize("loc_ingame_action_two") .. " - " .. Localize("loc_inventory_title_slot_secondary")
	},
	autoswitch_to_none = {
		en = "Don't Switch",
		["zh-cn"] = "不切换",
	},
	autoswitch_to_first = {
		en = "1st Person",
		["zh-cn"] = "第一人称",
	},
	autoswitch_to_third = {
		en = "3rd Person",
		["zh-cn"] = "第三人称",
	},
}

local crosshair_remap = get_mod("crosshair_remap")
if crosshair_remap and crosshair_remap.all_crosshair_names then
	mod._xhair_types = crosshair_remap.all_crosshair_names
	for _, type in ipairs(mod._xhair_types) do
		loc["xhair_" .. type] = {
			en = crosshair_remap:localize(type .. "_crosshair")
		}
	end
else
	mod._xhair_types = { "none", "cross", "assault", "bfg", "shotgun", "spray_n_pray", "dot" }
	for _, type in ipairs(mod._xhair_types) do
		loc["xhair_" .. type] = {
			en = Localize(type == "none" and "loc_setting_notification_type_none" or ("loc_setting_crosshair_type_override_" .. (type ~= "cross" and type or "killshot"))),
		}
	end
end

return loc
