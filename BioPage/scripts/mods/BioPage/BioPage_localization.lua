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
	archetype = {
		loc = "loc_class_selection_choose_class",
	},
	home_planet = {
		loc = "loc_character_birthplace_planet_title_name",
	},
	childhood = {
		loc = "loc_character_childhood_title_name",
	},
	growing_up = {
		loc = "loc_character_growing_up_title_name",
	},
	formative_event = {
		loc = "loc_character_event_title_name",
	},
	crime = {
		loc = "loc_character_create_title_crime",
		loc_adamant = "loc_character_create_title_precinct",
	},
	personality = {
		loc = "loc_character_create_title_personality",
	},
	summary = {
		loc = "loc_group_finder_category_story",
	},
}

for k, v in pairs(mod.bio_choices) do
	v.loc = v.loc and Localize(v.loc)
	v.loc_adamant = v.loc_adamant and Localize(v.loc_adamant)

	local text = v.loc
	if v.loc_adamant then
		text = text .. " / " .. v.loc_adamant
	end
	localization[k] = { en = text }
end

return localization
