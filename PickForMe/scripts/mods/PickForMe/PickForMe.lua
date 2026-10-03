local mod = get_mod("PickForMe")

local ItemUtils = require("scripts/utilities/items")
local MasterItems = require("scripts/backend/master_items")
local Mastery = require("scripts/utilities/mastery")
local PlayerProgressionUnlocks = require("scripts/settings/player/player_progression_unlocks")
local ProfileUtils = require("scripts/utilities/profile_utils")

local SPAM_BUFFER_TIME = 1.5
local next_valid_time = nil

mod:hook("StateMainMenu", "on_enter", function(func, self, parent, params, creation_context)
	if mod:get("random_character") then
		params.selected_profile = math.random_array_entry(params.profiles)
	end
	func(self, parent, params, creation_context)
end)

local _commit_loadout_slot = function(profile_preset_id, gear_id, slot)
	if gear_id and profile_preset_id then
		ProfileUtils.save_item_id_for_profile_preset(profile_preset_id, slot, gear_id)
	end
end

local _equip_item_from_pool = function(profile_preset_id, loadout, pools, pool_slot, equip_slot)
	local item = math.random_array_entry(pools[pool_slot])
	if item then
		for _, p in pairs(pools) do
			local idx = table.find(p, item)
			if idx ~= nil then
				table.remove(p, idx)
			end
		end

		if not equip_slot then
			equip_slot = pool_slot
		end

		-- Equip item
		return ItemUtils.equip_item_in_slot(equip_slot, item):next(function(success)
			if success then
				local item_gear_id = item and item.gear_id
				loadout[equip_slot] = item
				_commit_loadout_slot(profile_preset_id, item_gear_id, equip_slot)

				-- Update inventory view, in case it's open
				Managers.event:trigger("event_inventory_view_equip_item", equip_slot, item)
			end
		end)
	end
end

local _get_player = function()
	local gm_name = Managers.state and Managers.state.game_mode and Managers.state.game_mode:game_mode_name()
	local valid_gamemode = gm_name and (gm_name == "hub" or gm_name == "shooting_range")
	return valid_gamemode and Managers.player and Managers.player:local_player_safe(1) or nil
end

local _is_item_valid = function(item, profile)
	local archetype = profile.archetype
	local breed_valid = not item.breeds or table.contains(item.breeds, archetype.breed)
	local crime_valid = not item.crimes or table.contains(item.crimes, profile.lore.backstory.crime)
	local no_crimes = item.crimes == nil or table.is_empty(item.crimes)
	local archetype_valid = not item.archetypes or table.contains(item.archetypes, archetype.name)

	return archetype_valid and breed_valid and (no_crimes or crime_valid)
end

local _add_to_sublist = function(data, list_name, item)
	local list = data[list_name]
	if list then
		table.insert(list, item)
	else
		data[list_name] = { item }
	end
end

local add_target = function(randomize_data, arg)
	local target_data = mod.target_data[arg]
	if target_data then
		local slot = target_data.filter_slot or target_data.slot
		if slot then
			_add_to_sublist(randomize_data, "slots", slot)
		elseif target_data.mark then
			_add_to_sublist(randomize_data, "marks", target_data.mark)
		end
	end
end

local function add_aliasable_argument(randomize_data, uniques, arg)
	if not uniques[arg] then
		uniques[arg] = true

		local aliases = mod.arg_aliases[arg]
		if aliases then
			for i = 1, #aliases do
				add_aliasable_argument(randomize_data, uniques, aliases[i])
			end
		else
			add_target(randomize_data, arg)
		end
	end
end

local _randomize_slots = function(profile_preset_id, slot_filter, player)
	if slot_filter and #slot_filter > 0 then
		local character_id = player:character_id()
		local profile = player:profile()
		local loadout = profile.loadout
		local plr_level = profile.current_level
		return Managers.data_service.gear:fetch_inventory(character_id, slot_filter):next(function(items)
			local gear_pools = {}

			for _, item in pairs(items) do
				if _is_item_valid(item, profile) then
					for _, slot in pairs(item.slots) do
						if not gear_pools[slot] then
							gear_pools[slot] = {}
						end
						table.insert(gear_pools[slot], item)
					end
				end
			end
			mod.DBG_last_pool = gear_pools

			local equip_promises = {}
			for slot, _ in pairs(gear_pools) do
				local equip_promise = nil
				if slot == "slot_curio" then
					if plr_level >= PlayerProgressionUnlocks.gadget_slot_1 then
						equip_promise = _equip_item_from_pool(profile_preset_id, loadout, gear_pools, slot,
							"slot_attachment_1")
					end
					if plr_level >= PlayerProgressionUnlocks.gadget_slot_2 then
						equip_promise = _equip_item_from_pool(profile_preset_id, loadout, gear_pools, slot,
							"slot_attachment_2")
					end
					if plr_level >= PlayerProgressionUnlocks.gadget_slot_3 then
						equip_promise = _equip_item_from_pool(profile_preset_id, loadout, gear_pools, slot,
							"slot_attachment_3")
					end
				else
					equip_promise = _equip_item_from_pool(profile_preset_id, loadout, gear_pools, slot)
				end
				table.insert(equip_promises, equip_promise)
			end

			return Promise.all(unpack(equip_promises))
		end)
	end
	return Promise.resolved()
end

local _randomize_marks = function(profile_preset_id, slots, player)
	if slots and #slots > 0 then
		local mark_promises = {}
		local profile = player:profile()
		local loadout = profile.loadout

		local data_service = Managers.data_service
		for i = 1, #slots do
			local slot_name = slots[i]
			local item = loadout[slot_name]
			local pattern = item and item.parent_pattern
			if pattern then
				table.insert(mark_promises,
					data_service.mastery:get_mastery_by_pattern(pattern):next(function(mastery_data)
						local mark_milestones = Mastery.get_all_mastery_marks(mastery_data)
						local mark_id_pool = {}
						for m = 1, #mark_milestones do
							local mark = mark_milestones[m]
							if mark.unlocked then
								table.insert(mark_id_pool, mark.item.name)
							end
						end

						local gear_id = item.gear_id
						local mark_id = math.random_array_entry(mark_id_pool)
						if Managers.ui:view_active("inventory_background_view") then
							Managers.event:trigger("event_switch_mark", gear_id, mark_id)
							return Promise.resolved()
						end
						return data_service.mastery:switch_mark(gear_id, mark_id):next(function(switch_data)
							local gear = switch_data and switch_data.body and switch_data.body.gear
							loadout[slot_name] = MasterItems.get_item_instance(gear, gear_id)
							_commit_loadout_slot(profile_preset_id, gear_id, slot_name)
							data_service.gear:invalidate_gear_cache()
						end)
					end)
				)
			end
		end
		return Promise.all(unpack(mark_promises))
	end
	return Promise.resolved()
end

local _randomize_loadout = function(randomize_data)
	local this_t = Managers.time and Managers.time:time("main")
	if next_valid_time and this_t < next_valid_time then
		if mod:get("msg_invalid") then
			mod:notify(mod:localize("wait_a_sec"))
		end
		return
	end
	next_valid_time = this_t + SPAM_BUFFER_TIME

	local player = _get_player()
	if not player then
		if mod:get("msg_invalid") then
			mod:notify(mod:localize("bad_circumstance"))
		end
		return
	end

	if not randomize_data then
		randomize_data = {}
		for key, _ in pairs(mod.target_data) do
			if mod:get(key) then
				add_target(randomize_data, key)
			end
		end
	end

	local active_profile_preset_id = ProfileUtils.get_active_profile_preset_id()
	_randomize_slots(active_profile_preset_id, randomize_data.slots, player)
		:next(function()
			return _randomize_marks(active_profile_preset_id, randomize_data.marks, player)
		end)
		:next(function()
			if mod:get("msg_success") then
				mod:notify(mod:localize("randomize_finished"))
			end
		end)
		:catch(function(errors)
			mod:error(mod:localize("catch_error"))
			for k, v in pairs(errors) do
				mod:error("%s: %s", k, v)
			end
		end)
end

mod.quick_randomize = function()
	_randomize_loadout()
end

mod:command("pickforme", mod:localize("cmd_desc"), function(...)
	local randomize_data = nil

	local args = { ... }
	local arg_count = #args
	if arg_count > 0 then
		if table.contains(args, "help") then
			mod:echo(mod:localize("cmd_help"))
			return
		end

		randomize_data = {}
		local args_unique = {}
		for i = 1, arg_count do
			add_aliasable_argument(randomize_data, args_unique, args[i])
		end
	end

	_randomize_loadout(randomize_data)
end)
