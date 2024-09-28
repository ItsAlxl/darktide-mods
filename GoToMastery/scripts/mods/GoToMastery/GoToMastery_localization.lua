local mod = get_mod("GoToMastery")

local loc = {
	mod_name = {
		en = "GoToMastery",
		["zh-cn"] = "一键跳转专精",
	},
	mod_description = {
		en = "Adds a Mastery button to go to a selected weapon's Mastery menu.",
		["zh-cn"] = "添加专精按钮，用来前往已选武器的专精菜单。",
	},
}

mod.hotkey_data = {
	kb_marks = {
		display_name = Localize("loc_inventory_weapon_button_marks"),
	},
	kb_cosmetics = {
		display_name = Localize("loc_inventory_weapon_button_cosmetics"),
	},
	kb_inspect = {
		display_name = Localize("loc_inventory_weapon_button_inspect"),
		default = { "v" },
	},
	kb_mastery = {
		display_name = Localize("loc_mastery_mastery"),
	},
	kb_hadron = {
		display_name = Localize("loc_crafting_view_option_modify"),
	},
}

for key, data in pairs(mod.hotkey_data) do
	loc[key] = { en = data.display_name }
end

return loc
