local mod = get_mod("WhichMissions")
local AchievementStats = require("scripts/managers/stats/groups/achievement_stats")

local function _convert_class(s)
	if s == "zealot" or s == "preacher" then
		return "zealot"
	elseif s == "psyker" or s == "psykinetic" then
		return "psyker"
	elseif s == "veteran" or s == "sharpshooter" then
		return "veteran"
	elseif s == "ogryn" or s == "skullbreaker" then
		return "ogryn"
	end
	
	local _, _, class = string.find(Managers.player:local_player(1)._profile.specialization, "(.+)_%d")
	return class
end

local function _convert_class_difficulty(s)
	if s == "malice" then
		return 2
	elseif s == "heresy" then
		return 3
	end
	s = tonumber(s)
	if s then
		if s > 3 then
			return 3
		elseif s > 2 then
			return 2
		end
		return 1
	end
	return "%d"
end

local function _convert_account_difficulty(s)
	if s == "malice" then
		return 3
	elseif s == "heresy" then
		return 4
	end
	s = tonumber(s)
	if s then
		return s
	end
	return "%d"
end

local function _get_needed_objectives(filter_str, difficulty_filter, achievements_data)
	local needed_objectives = {}
	local auto_dfcl = difficulty_filter == "%d"

	filter_str = filter_str .. difficulty_filter .. "_objectives_"
	for id, _ in pairs(AchievementStats.definitions) do
		if string.find(id, filter_str) then
			local flag = Managers.data_service.account:read_stat(achievements_data, id)
			if flag == 0 then
				local _, _, dfcl, obj = string.find(id, "(%d)_objectives_(%d)")
				if auto_dfcl and (difficulty_filter == "%d" or dfcl < difficulty_filter) then
					for i=0, #needed_objectives do
						needed_objectives[i] = nil
					end
					difficulty_filter = dfcl
				end
				table.insert(needed_objectives, obj)
			end
		end
	end
	if difficulty_filter == "%d" then
		difficulty_filter = _convert_class_difficulty(5)
	end

	return needed_objectives, difficulty_filter
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
			readout = readout .. mod:localize("mission_type_" .. o)
		end
	end
	return readout, num_objs
end

local function _get_needed_readout(filter_str, difficulty_filter, achievements_data)
	local needed_objectives, dfcl = _get_needed_objectives(filter_str, difficulty_filter, achievements_data)
	local readout, num_objs = _get_objective_readout(needed_objectives)
	return readout, num_objs, dfcl
end

local function _get_class_needs(difficulty_filter, class_filter)
	Managers.data_service.account:pull_achievement_data():next(function (achievements_data)
		class_filter = _convert_class(class_filter)
		difficulty_filter = _convert_class_difficulty(difficulty_filter)

		local readout, num_objs, dfcl = _get_needed_readout("mission_" .. class_filter .. "_%d_", difficulty_filter, achievements_data)
		local dfcl_localized = mod:localize("difficulty_class_" .. dfcl)
		if num_objs == 0 then
			mod:echo(mod:localize("class_finished", class_filter, dfcl_localized))
		else
			mod:echo(mod:localize("class_needs", class_filter, num_objs, dfcl_localized, readout))
		end
	end,
	function ()
		mod:error("%s", "achivement data fetch failed")
	end)
end

local function _get_account_needs(difficulty_filter)
	Managers.data_service.account:pull_achievement_data():next(function (achievements_data)
		difficulty_filter = _convert_account_difficulty(difficulty_filter)
		
		local readout, num_objs, dfcl = _get_needed_readout("mission_difficulty_", difficulty_filter, achievements_data)
		local dfcl_localized = mod:localize("difficulty_account_" .. dfcl)
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
