local mod = get_mod("ToggleAltFire")

local ArchetypeTalents = require("scripts/settings/ability/archetype_talents/archetype_talents")
local Pickups = require("scripts/settings/pickup/pickups")
local UiWeaponPatternSettings = require("scripts/settings/ui/ui_weapon_pattern_settings")
local WeaponTemplates = require("scripts/settings/equipment/weapon_templates/weapon_templates")

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
	_sprint_pickup = {
		en = Localize("loc_ingame_sprint") .. " - " .. Localize("loc_item_type_pocketable")
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
	},
	optgroup_blitzes = {
		en = Localize("loc_glossary_term_tactical")
	},
	optgroup_pickups = {
		en = Localize("loc_item_type_pocketable")
	},
}

mod.weapon_to_family = function(weapon_id)
	return string.sub(weapon_id, 1, string.len(weapon_id) - 3) or nil
end

local pocketables = Pickups.by_group.pocketable
local inventory_talent_names = {}
for archetype, talents in pairs(ArchetypeTalents) do
	for _, definition in pairs(talents) do
		local ability = definition.player_ability and definition.player_ability.ability
		local item_name = ability and ability.inventory_item_name
		if item_name then
			inventory_talent_names[item_name] = Localize("loc_class_" .. archetype .. "_name")
				.. " - "
				.. Localize(definition.display_name)
		end
	end
end

mod.pickups = {}
mod.weapon_families = {}
mod.blitzes = {}
local track_template = function(target_list, id, loc)
	table.insert(target_list, id)
	localization[id] = { en = loc }
end

for weapon_id, weapon_template in pairs(WeaponTemplates) do
	local keywords = weapon_template.keywords
	if keywords and not weapon_template.is_grenade_ability_weapon then -- already covered by blitz options
		local is_ranged = false
		local is_grenade = false
		for i = 1, #keywords do
			local k = keywords[i]
			if k == "ranged" then
				is_ranged = true
			end
			if k == "grenade" then
				is_grenade = true
			end
		end

		local can_aim = weapon_template.actions.action_aim ~= nil
		local pickup = weapon_template.swap_pickup_name and pocketables[weapon_template.swap_pickup_name]
		if pickup then
			if can_aim then
				track_template(mod.pickups, weapon_id, Localize(pickup.description))
			end
		elseif is_ranged then
			local family_id = mod.weapon_to_family(weapon_id)
			local family = family_id and UiWeaponPatternSettings[family_id]
			if family and not table.contains(mod.weapon_families, family_id) then
				track_template(mod.weapon_families, family_id, Localize(family.display_name))
			end
		elseif is_grenade and can_aim then
			local projectile = weapon_template.projectile_template
			local item = projectile and projectile.item_name
			local display_name = item and inventory_talent_names[item]
			if display_name then
				track_template(mod.blitzes, weapon_id, display_name)
			end
		end
	end
end

return localization
