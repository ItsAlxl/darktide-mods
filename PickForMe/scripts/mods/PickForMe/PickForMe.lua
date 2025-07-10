local mod = get_mod("PickForMe")

local ItemUtils = require("scripts/utilities/items")
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

local _equip_item_from_pool = function(pools, pool_slot, equip_slot)
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
		ItemUtils.equip_item_in_slot(equip_slot, item)

		local item_gear_id = item and item.gear_id
		local active_profile_preset_id = ProfileUtils.get_active_profile_preset_id()
		if item_gear_id and active_profile_preset_id then
			ProfileUtils.save_item_id_for_profile_preset(active_profile_preset_id, equip_slot, item_gear_id)
		end

		-- Update inventory view, in case it's open
		Managers.event:trigger("event_inventory_view_equip_item", equip_slot, item)
	end
end

local _get_player = function()
	local gm_name = Managers.state and Managers.state.game_mode and Managers.state.game_mode:game_mode_name()
	local valid_gamemode = gm_name and (gm_name == "hub" or gm_name == "shooting_range")
	return valid_gamemode and Managers.player and Managers.player:local_player_safe(1) or nil
end

local _is_item_valid = function(item, player)
	local profile = player:profile()
	local archetype = profile.archetype
	local breed_valid = not item.breeds or table.contains(item.breeds, archetype.breed)
	local crime_valid = not item.crimes or table.contains(item.crimes, profile.lore.backstory.crime)
	local no_crimes = item.crimes == nil or table.is_empty(item.crimes)
	local archetype_valid = not item.archetypes or table.contains(item.archetypes, archetype.name)

	return archetype_valid and breed_valid and (no_crimes or crime_valid)
end

local add_to_slot_filter = function(filter, key)
	local slot_data = mod.slot_data[key]
	if slot_data then
		table.insert(filter, slot_data.filter_slot or slot_data.slot)
	end
end

local add_to_slot_filter_from_args = function(filter, args, key)
	if table.contains(args, key) then
		add_to_slot_filter(filter, key)
	end
end

local _randomize_loadout = function(slot_filter)
	if not slot_filter then
		slot_filter = {}
		for key, _ in pairs(mod.slot_data) do
			if mod:get(key) then
				add_to_slot_filter(slot_filter, key)
			end
		end
	end

	if #slot_filter > 0 then
		local player = _get_player()
		if not player then
			if mod:get("msg_invalid") then
				mod:notify(mod:localize("bad_circumstance"))
			end
			return
		end

		local this_t = Managers.time and Managers.time:time("main")
		if next_valid_time and this_t < next_valid_time then
			if mod:get("msg_invalid") then
				mod:notify(mod:localize("wait_a_sec"))
			end
			return
		end
		next_valid_time = this_t + SPAM_BUFFER_TIME

		local character_id = player:character_id()
		local profile = player:profile()
		local plr_level = profile.current_level
		Managers.data_service.gear:fetch_inventory(character_id, slot_filter):next(function(items)
			local gear_pools = {}

			for _, item in pairs(items) do
				if _is_item_valid(item, player) then
					for _, slot in pairs(item.slots) do
						if not gear_pools[slot] then
							gear_pools[slot] = {}
						end
						table.insert(gear_pools[slot], item)
					end
				end
			end

			for slot, _ in pairs(gear_pools) do
				if slot == "slot_curio" then
					if plr_level >= PlayerProgressionUnlocks.gadget_slot_1 then
						_equip_item_from_pool(gear_pools, slot, "slot_attachment_1")
					end
					if plr_level >= PlayerProgressionUnlocks.gadget_slot_2 then
						_equip_item_from_pool(gear_pools, slot, "slot_attachment_2")
					end
					if plr_level >= PlayerProgressionUnlocks.gadget_slot_3 then
						_equip_item_from_pool(gear_pools, slot, "slot_attachment_3")
					end
				else
					_equip_item_from_pool(gear_pools, slot)
				end
			end
		end):catch(function(errors)
			mod:error(mod:localize("catch_error"))
			for k, v in pairs(errors) do
				mod:error("%s: %s", k, v)
			end
		end)
	end
end

mod.quick_randomize = function()
	_randomize_loadout()
end

mod:command("pickforme", mod:localize("cmd_desc"), function(...)
	local slot_filter = nil

	local args = { ... }
	if #args > 0 then
		if table.contains(args, "help") then
			mod:echo(mod:localize("cmd_help"))
			return
		end

		slot_filter = {}
		if table.contains(args, "all") then
			add_to_slot_filter(slot_filter, "primary")
			add_to_slot_filter(slot_filter, "secondary")
			add_to_slot_filter(slot_filter, "curios")
			add_to_slot_filter(slot_filter, "hat")
			add_to_slot_filter(slot_filter, "shirt")
			add_to_slot_filter(slot_filter, "pants")
			add_to_slot_filter(slot_filter, "back")
			add_to_slot_filter(slot_filter, "frame")
			add_to_slot_filter(slot_filter, "insignia")
			add_to_slot_filter(slot_filter, "pose")
			add_to_slot_filter(slot_filter, "dog")
		else
			if table.contains(args, "gear") then
				add_to_slot_filter(slot_filter, "primary")
				add_to_slot_filter(slot_filter, "secondary")
				add_to_slot_filter(slot_filter, "curios")
			else
				if table.contains(args, "weapons") then
					add_to_slot_filter(slot_filter, "primary")
					add_to_slot_filter(slot_filter, "secondary")
				else
					add_to_slot_filter_from_args(slot_filter, args, "primary")
					add_to_slot_filter_from_args(slot_filter, args, "secondary")
				end
				add_to_slot_filter_from_args(slot_filter, args, "curios")
			end

			if table.contains(args, "cosmetics") then
				add_to_slot_filter(slot_filter, "hat")
				add_to_slot_filter(slot_filter, "shirt")
				add_to_slot_filter(slot_filter, "pants")
				add_to_slot_filter(slot_filter, "back")
				add_to_slot_filter(slot_filter, "frame")
				add_to_slot_filter(slot_filter, "insignia")
				add_to_slot_filter(slot_filter, "pose")
				add_to_slot_filter(slot_filter, "dog")
			else
				if table.contains(args, "clothes") then
					add_to_slot_filter(slot_filter, "hat")
					add_to_slot_filter(slot_filter, "shirt")
					add_to_slot_filter(slot_filter, "pants")
					add_to_slot_filter(slot_filter, "back")
				else
					add_to_slot_filter_from_args(slot_filter, args, "hat")
					add_to_slot_filter_from_args(slot_filter, args, "shirt")
					add_to_slot_filter_from_args(slot_filter, args, "pants")
					add_to_slot_filter_from_args(slot_filter, args, "back")
				end

				if table.contains(args, "portrait") then
					add_to_slot_filter(slot_filter, "frame")
					add_to_slot_filter(slot_filter, "insignia")
				else
					add_to_slot_filter_from_args(slot_filter, args, "frame")
					add_to_slot_filter_from_args(slot_filter, args, "insignia")
				end

				add_to_slot_filter_from_args(slot_filter, args, "pose")
				add_to_slot_filter_from_args(slot_filter, args, "dog")
			end
		end
	end

	_randomize_loadout(slot_filter)
end)
