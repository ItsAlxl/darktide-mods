local mod = get_mod("ToggleAltFire")

local ArchetypeTalents = require("scripts/settings/ability/archetype_talents/archetype_talents")
local UiWeaponPatternSettings = require("scripts/settings/ui/ui_weapon_pattern_settings")
local WeaponTemplates = require("scripts/settings/equipment/weapon_templates/weapon_templates")

mod.weapon_to_family = function(weapon_id)
	return string.sub(weapon_id, 1, string.len(weapon_id) - 3) or nil
end

-- unfortunately, this doesn't exist in the base game
-- the closest is a fetched list; but by the time it's fetched, it's too late
local blitz_to_template = {
	adamant_grenade = "adamant_grenade",
	adamant_grenade_improved = "adamant_grenade",
	adamant_shock_mine = "shock_mine",
	broker_blitz_flash_grenade = "quick_flash_grenade",
	broker_blitz_flash_grenade_improved = "quick_flash_grenade",
	broker_blitz_tox_grenade = "tox_grenade",
	cryptic_grenade_ability_arc_grenade = "arc_grenade",
	ogryn_box_explodes = "ogryn_grenade_box_cluster",
	ogryn_grenade_box = "ogryn_grenade_box",
	ogryn_grenade_frag = "ogryn_grenade_frag",
	ogryn_grenade_friend_rock = "ogryn_grenade_friend_rock",
	veteran_frag_grenade = "frag_grenade",
	veteran_krak_grenade = "krak_grenade",
	veteran_smoke_grenade = "smoke_grenade",
	zealot_flame_grenade = "fire_grenade",
	zealot_shock_grenade = "shock_grenade",
}

--[[ Use this to find missing blitzes; only works after initial load
local MasterItems = require("scripts/backend/master_items")
local missing_blitzes = {}
local any_missing = false
for _, archetype_talents in pairs(ArchetypeTalents) do
	for talent_id, definition in pairs(archetype_talents) do
		local ability = definition.player_ability and definition.player_ability.ability
		if ability and ability.ability_type == "grenade_ability" then
			local blitz_item = MasterItems.get_item(ability.inventory_item_name)
			local template_id = blitz_item and blitz_item.weapon_template
			if template_id and (not blitz_to_template[talent_id] or blitz_to_template[talent_id] ~= template_id) then
				local template = WeaponTemplates[template_id]
				if template and template.actions and template.actions.action_aim then
					missing_blitzes[talent_id] = template_id
					any_missing = true
				end
			end
		end
	end
end
if any_missing then
	mod:echo("Add the following blitzes to ToggleAltFire's blitz_to_template:")
	for talent_id, template_id in pairs(missing_blitzes) do
		mod:echo("%s = \"%s\"", talent_id, template_id)
	end
else
	mod:echo("No blitzes missing for ToggleAltFire")
end
--]]

mod.blitz_data = {}
for player_archetype, archetype_talents in pairs(ArchetypeTalents) do
	for talent_id, definition in pairs(archetype_talents) do
		local ability = definition.player_ability and definition.player_ability.ability
		if ability and ability.ability_type == "grenade_ability" then
			local template_id = blitz_to_template[talent_id]
			if template_id and not mod.blitz_data[template_id] then
				mod.blitz_data[template_id] = {
					loc = Localize("loc_class_" .. player_archetype .. "_name")
						.. " - " .. Localize(definition.display_name)
				}
			end
		end
	end
end

mod.weapon_family_data = {}
for weapon_id, weapon_template in pairs(WeaponTemplates) do
	local keywords = weapon_template.keywords
	if keywords and not weapon_template.is_grenade_ability_weapon then -- already covered by blitz options
		local is_ranged = false
		for i = 1, #keywords do
			if keywords[i] == "ranged" then
				is_ranged = true
			end
		end

		local family_id = is_ranged and mod.weapon_to_family(weapon_id)
		local family = family_id and UiWeaponPatternSettings[family_id]
		if family and not mod.weapon_family_data[family_id] then
			mod.weapon_family_data[family_id] = {
				loc = Localize(family.display_name)
			}
		end
	end
end

local localization = {
	mod_description = {
		en = "Toggle the alternate fire (aiming, charged shot, etc.) of ranged weapons.",
		["zh-cn"] = "切换式远程武器次要动作（瞄准、蓄力等）。",
	},
	optgroup_untoggle_acts = {
		en = "Untoggle Actions",
		["zh-cn"] = "取消切换的动作",
	},
	action_reload = {
		en = Localize("loc_ingame_weapon_reload")
	},
	action_start_reload = {
		en = "One-at-a-Time " .. Localize("loc_ingame_weapon_reload"),
		["zh-cn"] = "单发装填武器",
	},
	action_vent = {
		en = Localize("loc_weapon_special_weapon_vent")
	},
	_sprint_base = {
		en = Localize("loc_ingame_sprint")
	},
	_sprint_staff = {
		en = Localize("loc_ingame_sprint") .. " - Force Staves",
		["zh-cn"] = Localize("loc_ingame_sprint") .. " - 力场杖",
	},
	_sprint_blitz = {
		en = Localize("loc_ingame_sprint") .. " - " .. Localize("loc_talents_category_tactical")
	},
	action_lunge = {
		en = "Dash Ability",
		["zh-cn"] = "冲锋（欧格林/狂信徒能力）",
	},
	action_shoot_charged = {
		en = "Plasma/Staff - " .. Localize("loc_glossary_term_charge"),
		["zh-cn"] = "充能射击（等离子枪/力场杖）",
	},
	action_shoot_braced = {
		en = "Flamer - " .. Localize("loc_ranged_attack_secondary_braced"),
		["zh-cn"] = "持续射击（火焰喷射器）",
	},
	action_melee_extra = {
		en = Localize("loc_weapon_special") .. " - " .. Localize("loc_weapon_special_weapon_bash"),
		["zh-cn"] = "近战武器特殊攻击",
	},
	optgroup_weps = {
		en = Localize("loc_glossary_term_ranged_weapons"),
		["zh-cn"] = "远程武器次要动作切换",
	},
	optgroup_blitzes = {
		en = Localize("loc_talents_category_tactical")
	},
}

for k, w in pairs(mod.weapon_family_data) do
	localization[k] = { en = w.loc }
end
for k, b in pairs(mod.blitz_data) do
	localization[k] = { en = b.loc }
end

return localization
