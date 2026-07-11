local mod = get_mod("ServoSkullNametag")

local SpecialRules = require("scripts/settings/ability/special_rules_settings").special_rules
local Nameplate = mod:io_dofile("ServoSkullNametag/scripts/mods/ServoSkullNametag/Nameplate")

mod:io_dofile("ServoSkullNametag/scripts/mods/ServoSkullNametag/InventoryView")

local skull_nameplates = {}
local remote_skull_names = {}

mod:hook(CLASS.HudElementWorldMarkers, "init", function(func, self, ...)
	func(self, ...)
	local marker_templates = self._marker_templates
	if marker_templates and not marker_templates.servoskull_nametag then
		marker_templates.servoskull_nametag = Nameplate
	end
end)

local get_skull_id = function(player, skull_type)
	local profile = player and player:profile()
	return profile and ("_" .. profile.character_id .. "_" .. skull_type) or nil
end

local create_skull_nameplate = function(HudElementNameplates, companion_unit, player, skull_type)
	HudElementNameplates._companion_nameplates[companion_unit] = {
		marker_id = nil,
		synced = true,
	}

	local skull_id = get_skull_id(player, skull_type)
	if skull_id then
		Managers.event:trigger(
			"add_world_marker_unit",
			"servoskull_nametag",
			companion_unit,
			function(id)
				HudElementNameplates:_on_companion_nameplate_marker_spawned(companion_unit, id)
			end,
			{
				player = player,
				skull_type = skull_type,
				in_hub = HudElementNameplates._is_mission_hub,
				skull_id = skull_id,
			}
		)
	end
end

mod:hook(CLASS.HudElementNameplates, "_add_companion_nameplate",
	function(func, self, marker_type, companion_unit, player)
		func(self, marker_type, companion_unit, player)

		local player_unit = player.player_unit
		if player_unit and ALIVE[player_unit] and ALIVE[companion_unit] then
			local companion_spawner_extension = ScriptUnit.has_extension(player.player_unit, "companion_spawner_system")
			local skulls = companion_spawner_extension and {
				base = companion_spawner_extension:spawned_unit_lookup(SpecialRules.cryptic_servo_skull_hack),
				flame = companion_spawner_extension:spawned_unit_lookup(SpecialRules.cryptic_servo_skull_flamethrower),
				med = companion_spawner_extension:spawned_unit_lookup(SpecialRules.cryptic_servo_skull_inject_ally),
			}

			if skulls then
				for type, unit in pairs(skulls) do
					if unit == companion_unit then
						create_skull_nameplate(self, unit, player, type)
					end
				end
			end
		end
	end)

mod.track_nameplate = function(marker)
	skull_nameplates[marker.data.skull_id] = marker
end

mod.untrack_nameplate = function(marker)
	local skull_id = marker.data.skull_id
	skull_nameplates[skull_id] = nil
	if remote_skull_names[skull_id] then
		remote_skull_names[skull_id] = nil
	end
end

mod.refresh_marker_text_by_id = function(skull_id)
	local nameplate = skull_nameplates[skull_id]
	if nameplate then
		mod.refresh_marker_text(nameplate)
	end
end

mod.on_setting_changed = function(id)
	if id == "vis_hub" or id == "vis_mission" then
		for _, marker in pairs(skull_nameplates) do
			mod.refresh_marker_visibility(marker)
		end
	end
end

mod.set_my_skull_name = function(skull_type, name)
	local me = Managers and Managers.player and Managers.player:local_player_safe(1)
	local skull_id = me and get_skull_id(me, skull_type)
	if skull_id then
		mod:set(skull_id, name)
		mod.refresh_marker_text_by_id(skull_id)
	end
end

mod.set_other_skull_name = function(player, skull_type, name)
	local skull_id = get_skull_id(player, skull_type)
	if skull_id then
		remote_skull_names[skull_id] = name
		mod.refresh_marker_text_by_id(skull_id)
	end
end

mod.get_skull_name = function(player, skull_type)
	local skull_id = get_skull_id(player, skull_type)
	local n = skull_id
		and (player:peer_id() == Network.peer_id() and mod:get(skull_id) or remote_skull_names[skull_id])
		or ""
	return n
end

local set_name_from_cmd = function(type, ...)
	mod.set_my_skull_name(type, table.concat({ ... }, " "))
end

mod:command("name_base_skull", mod:localize("cmd_name_base_skull"), function(...)
	set_name_from_cmd("base", ...)
end)
mod:command("name_flame_skull", mod:localize("cmd_name_flame_skull"), function(...)
	set_name_from_cmd("flame", ...)
end)
mod:command("name_med_skull", mod:localize("cmd_name_med_skull"), function(...)
	set_name_from_cmd("med", ...)
end)
