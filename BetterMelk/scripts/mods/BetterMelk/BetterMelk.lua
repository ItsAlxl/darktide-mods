local mod = get_mod("BetterMelk")
local PlayerProgressionUnlocks = require("scripts/settings/player/player_progression_unlocks")
local Style = mod:io_dofile("BetterMelk/scripts/mods/BetterMelk/PassTemplates")

local profile_to_widget = mod:persistent_table("profile_to_widget")

local _get_contracts_string = function(num_completed, num_tasks, finished, bonus_rewarded)
	local s = num_completed .. "/" .. num_tasks .. ""
	if finished then
		if bonus_rewarded then
			s = s .. " []"
		else
			s = s .. " [!]"
		end
	end
	return s
end

local _update_contracts_lbl = function(widget, contract_data)
	if contract_data then
		local contract_tasks = contract_data.tasks
		local num_tasks_completed = 0
		local num_tasks = #contract_tasks
		for _, task in pairs(contract_tasks) do
			if task.fulfilled then
				num_tasks_completed = num_tasks_completed + 1
			end
		end
		widget.content.contracts_text = _get_contracts_string(
			num_tasks_completed,
			num_tasks,
			contract_data.fulfilled,
			contract_data.rewarded
		)
	else
		widget.content.contracts_text = "---"
	end
end

local _auto_melk = function(profile, char_screen_widget)
	if not char_screen_widget then
		char_screen_widget.content.contracts_text = "---"
		return
	end
	local character_id = profile.character_id
	local interface = Managers.data_service.contracts._backend_interface.contracts
	local promise = interface:get_current_contract(character_id)
	if promise then
		promise:next(function(contract_data)
			_update_contracts_lbl(char_screen_widget, contract_data)
		end)
	else
		mod:error("msg_error")
	end
end

mod.refresh_profile = function(profile)
	local widget = profile_to_widget[profile]
	if not widget or not widget.content then
		return
	end

	_auto_melk(profile, widget)
end

mod.refresh_all_profiles = function()
	for profile, _ in pairs(profile_to_widget) do
		mod.refresh_profile(profile)
	end
end

mod.refresh_all_style = function()
	for _, widget in pairs(profile_to_widget) do
		for style_id, style in pairs(Style.get_style_update()) do
			local target = widget.style[style_id]
			if target then
				table.merge_recursive(target, style)
			end
		end
	end
end

mod.refresh_all = function()
	mod.refresh_all_style()
	mod.refresh_all_profiles()
end

mod:hook(CLASS.MainMenuView, "_sync_character_slots", function(func, ...)
	table.clear(profile_to_widget)
	func(...)
	mod.refresh_all_style()
end)

mod:hook_safe(CLASS.MainMenuView, "_set_player_profile_information", function(self, profile, widget)
	profile_to_widget[profile] = widget
	mod.refresh_profile(profile)
end)

mod:hook_safe(CLASS.UIViewHandler, "close_view", function(self, view_name, ...)
	if view_name == "dmf_options_view" then
		mod.refresh_all()
	end
end)

mod.on_disabled = function()
	mod.refresh_all_style()
end

mod.on_enabled = function()
	mod.refresh_all()
end
