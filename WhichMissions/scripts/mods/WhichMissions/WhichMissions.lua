local mod = get_mod("WhichMissions")
local DangerSettings = require("scripts/settings/difficulty/danger_settings")

local num_objective_types = 7
local num_difficulties = 5
local num_difficulties_class = 3

local function _convert_class(s)
	if s == "zealot" or s == "preacher" then
		return "zealot_2", "loc_class_zealot_title"
	elseif s == "psyker" or s == "psykinetic" then
		return "psyker_2", "loc_class_psyker_title"
	elseif s == "veteran" or s == "sharpshooter" then
		return "veteran_2", "loc_class_veteran_title"
	elseif s == "ogryn" or s == "skullbreaker" then
		return "ogryn_2", "loc_class_ogryn_title"
	end

	local profile = Managers.player:local_player(1)._profile
	return profile.specialization, profile.archetype.archetype_title
end

local function _convert_account_difficulty(s)
	if s == "sedition" then
		return 1
	elseif s == "uprising" then
		return 2
	elseif s == "malice" then
		return 3
	elseif s == "heresy" then
		return 4
	elseif s == "damnation" then
		return 5
	end
	s = tonumber(s)
	if s then
		return math.min(s, num_difficulties)
	end
	return -1
end

local function _convert_class_difficulty(s)
	s = _convert_account_difficulty(s)
	if s > 3 then
		return 3
	elseif s > 2 then
		return 2
	elseif s > 0 then
		return 1
	else
		return -1
	end
end

local function _localize_class_difficulty(s)
	if s == 3 then
		return Localize(DangerSettings.by_index[4].display_name)
	elseif s == 2 then
		return Localize(DangerSettings.by_index[3].display_name)
	elseif s == 1 then
		return mod:localize("difficulty_class_any")
	else
		return ""
	end
end

local function _get_flag_value(pfx, difficulty, objective, achievements_data)
	return Managers.data_service.account:read_stat(achievements_data, pfx .. "_" .. difficulty .. "_objectives_" .. objective .. "_flag")
end

local function _is_difficulty_finished(flag_pfx, difficulty, achievements_data)
	for i = 1, num_objective_types do
		if _get_flag_value(flag_pfx, difficulty, i, achievements_data) == 0 then
			return false
		end
	end
	return true
end

local function _get_needed_objectives(flag_pfx, difficulty, max_difficulty, achievements_data)
	local needed_objectives = {}
	if difficulty < 1 then
		difficulty = 1
		while difficulty < max_difficulty and _is_difficulty_finished(flag_pfx, difficulty, achievements_data) do
			difficulty = difficulty + 1
		end
	end
	for i = 1, num_objective_types do
		if _get_flag_value(flag_pfx, difficulty, i, achievements_data) == 0 then
			table.insert(needed_objectives, i)
		end
	end
	return needed_objectives, difficulty
end

local function _get_objective_readout(needed_objectives)
	local num_objs = #needed_objectives
	local readout = ""
	if num_objs > 0 then
		table.sort(needed_objectives)
		for _, o in pairs(needed_objectives) do
			if readout ~= "" then
				readout = readout .. ", "
			end
			readout = readout .. Localize(string.format("loc_mission_type_%02d_name", o))
		end
	end
	return readout, num_objs
end

local function _get_needed_readout(flag_pfx, difficulty, max_difficulty, achievements_data)
	local needed_objectives, dfcl = _get_needed_objectives(flag_pfx, difficulty, max_difficulty, achievements_data)
	local readout, num_objs = _get_objective_readout(needed_objectives)
	return readout, num_objs, dfcl
end

local function _get_class_needs(difficulty_filter, class_filter)
	Managers.data_service.account:pull_achievement_data():next(function (achievements_data)
		local class_filter, class_title = _convert_class(class_filter)
		difficulty_filter = _convert_class_difficulty(difficulty_filter)

		local readout, num_objs, dfcl = _get_needed_readout("_mission_" .. class_filter, difficulty_filter, num_difficulties_class, achievements_data)
		local dfcl_localized = _localize_class_difficulty(dfcl)
		local class_localized = Localize(class_title)
		if num_objs == 0 then
			mod:echo(mod:localize("class_finished", class_localized, dfcl_localized))
		else
			mod:echo(mod:localize("class_needs", class_localized, num_objs, dfcl_localized, readout))
		end
	end,
	function ()
		mod:error("%s", "achivement data fetch failed")
	end)
end

local function _get_account_needs(difficulty_filter)
	Managers.data_service.account:pull_achievement_data():next(function (achievements_data)
		difficulty_filter = _convert_account_difficulty(difficulty_filter)
		
		local readout, num_objs, dfcl = _get_needed_readout("_mission_difficulty", difficulty_filter, num_difficulties, achievements_data)
		local dfcl_localized = Localize(DangerSettings.by_index[dfcl].display_name)
		if num_objs == 0 then
			mod:echo(mod:localize("account_finished", dfcl_localized))
		else
			mod:echo(mod:localize("account_needs", num_objs, dfcl_localized, readout))
		end
	end,
	function (ad)
		mod:error("%s", "achivement data fetch failed")
	end)
end

mod:command("wm_account", mod:localize("cmd_desc_account"), function(...)
	_get_account_needs(...)
end)

mod:command("wm_class", mod:localize("cmd_desc_class"), function(...)
	_get_class_needs(...)
end)

mod:command("wm_help", mod:localize("cmd_desc_help"), function()
	mod:echo(mod:localize("mod_help"))
end)
