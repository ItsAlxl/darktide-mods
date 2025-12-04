local mod = get_mod("BioPage")

local localization = {
	mod_name = {
		en = "BioPage",
		["zh-cn"] = "个人传记",
		ru = "Страница биографии",
	},
	mod_description = {
		en = "Adds a Biography page for you and other players",
		["zh-cn"] = "为您和其他玩家添加一个传记页面，用于说明该玩家选择的出生背景故事",
		ru = "BioPage - Добавляет страницу биографии для вас и других игроков.",
	},
	bio_tab_name = {
		en = "Biography",
		["zh-cn"] = "背景故事",
		ru = "Биография",
	},
}

mod.bio_choices = {
	base = {
		archetype = "loc_class_selection_choose_class",
		home_planet = "loc_character_create_title_home_planet",
		childhood = "loc_character_childhood_title_name",
		growing_up = "loc_character_growing_up_title_name",
		formative_event = "loc_character_event_title_name",
		crime = "loc_character_create_title_crime",
		personality = "loc_character_create_title_personality",
		summary = "loc_group_finder_category_story",
	},
	adamant = {
		childhood = "loc_character_create_title_early_life",
		growing_up = "loc_character_create_title_key_event",
		formative_event = "loc_character_create_title_commendations",
		crime = "loc_character_create_title_precinct",
	},
	broker = {
		home_planet = "loc_character_create_title_gang",
	},
}

mod.get_bio_title = function(id, archetype)
	local choices = mod.bio_choices
	local archetype_overrides = archetype and choices[archetype]
	return archetype_overrides and archetype_overrides[id] or choices.base[id]
end

for choice, loc in pairs(mod.bio_choices.base) do
	local localized_list = { Localize(loc) }
	local hash = { [localized_list[1]] = true }

	for archetype, overrides in pairs(mod.bio_choices) do
		local override = overrides[choice]
		local localized = override and Localize(override)
		if localized and archetype ~= "base" and not hash[localized] then
			localized_list[#localized_list + 1] = localized
			hash[localized] = true
		end
	end

	localization[choice] = { en = table.concat(localized_list, " / ") }
end

return localization
