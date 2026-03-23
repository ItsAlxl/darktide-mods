local mod = get_mod("MissionMechanismDebugger")

local Havoc = require("scripts/utilities/havoc")

local MissionBrief = nil
local LobbyModifierInfo = nil

mod.on_all_mods_loaded = function()
	MissionBrief = get_mod("MissionBrief")
	LobbyModifierInfo = get_mod("LobbyModifierInfo")
end

local _extract_and_validate_node_id = function(mission_flags)
	if not mission_flags then
		return nil
	end

	local node_id = nil
	local prefix = "exped-node-"
	for flag, _ in pairs(mission_flags) do
		local a, b = string.find(flag, prefix, 1, true)

		if a == 1 and b == #prefix then
			if node_id then
				return nil
			end
			node_id = string.sub(flag, #prefix + 1)
		end
	end
	return node_id
end

mod:command(
	"dbg_mech",
	"Toggle view (l/s) for gamemode (a/h/e)",
	function(view_id, gamemode_id)
		view_id = view_id and string.sub(view_id, 1, 1) or "s"
		gamemode_id = gamemode_id and string.sub(gamemode_id, 1, 1) or "a"

		local ship_view_name = "mission_intro_view"
		local lobby_view_name = "lobby_view"
		if Managers.ui:view_active(ship_view_name) then
			Managers.ui:close_view(ship_view_name)
		elseif Managers.ui:view_active(lobby_view_name) then
			Managers.ui:close_view(lobby_view_name)
		else
			local target_mod = view_id == "l" and LobbyModifierInfo or MissionBrief
			if not target_mod then
				mod:echo("Mod not installed")
				return
			end

			local target_view_name = view_id == "l" and lobby_view_name or ship_view_name
			local finish = function(mech_data)
				target_mod.mech_data_override = mech_data
				mod.last_spoofed_mech_data = mech_data
				Managers.ui:open_view(target_view_name, nil, false, true, nil,
					view_id == "l" and {
						preview = true,
						debug_preview = true,
						debug_unparsed_havoc_data = mech_data.havoc_data,
						mission_data = {
							circumstance_name = mech_data.circumstance_name,
							mission_name = mech_data.mission_name,
							backend_mission_id = mech_data.backend_mission_id
						},
					}
					or nil
				)
			end

			if gamemode_id == "e" then
				local mech_data = {
					challenge = 4,
					level_name = "content/levels/expeditions/start/world",
					resistance = 4,
					circumstance_name = "exps_dark",
					backend_mission_id = "missionbrief_dbg_" .. gamemode_id,
					mission_giver_vo_override = "tech_priest_a",
					mission_name = "exp_wastes",
					side_mission = "default",
					expedition_template_name = "wastes"
				}

				Managers.data_service.expedition:fetch_expedition_missions():next(function(expeditions_data)
					local highest_modifiers = -1
					mod.fetched_expeds = expeditions_data
					for _, mission in ipairs(expeditions_data) do
						if mission.modifiers then
							local num_modifiers = #mission.modifiers
							if num_modifiers > highest_modifiers then
								highest_modifiers = num_modifiers
								mech_data.node_id = _extract_and_validate_node_id(mission.flags)
								mech_data.backend_mission_id = mission.id
							end
						end
					end
					finish(mech_data)
				end):catch(function(error)
					mod:error(tostring(table.tostring(error, 1)))
					finish(mech_data)
				end)
			else
				local mech_data = {
					challenge = 4,
					level_name = "content/levels/transit/missions/mission_cm_habs",
					resistance = 4,
					circumstance_name = gamemode_id == "h" and "default" or "darkness_hunting_grounds_01",
					backend_mission_id = "missionbrief_dbg_" .. gamemode_id,
					mission_giver_vo_override = "sergeant_b",
					mission_name = "fm_resurgence",
					side_mission = "side_mission_tome",
					havoc_data = gamemode_id == "h"
						and
						"km_heresy;31;darkness;cultist;mutator_encroaching_garden:mutator_highest_difficulty:mutator_havoc_chaos_rituals:darkness_hunting_grounds_01;26.4:1.5:4.4:13.5:7.5:11.4:10.4:8.4:9.4:6.5:12.5:22.4:23.5:5.4:3.4:2.4:25.4:24.4;5;5"
						or nil
				}
				finish(mech_data)
			end
		end
	end
)

mod:hook_safe(CLASS.MissionIntroView, "on_enter", function(...)
	local mech_data = Managers.mechanism:mechanism_data()
	local havoc_data = mech_data.havoc_data and Havoc.parse_data(mech_data.havoc_data)
	mod.last_ship_data = {
		mech = mech_data,
		havoc = havoc_data,
	}
end)

mod:hook_safe(CLASS.LobbyView, "on_enter", function(...)
	local mech_data = Managers.mechanism:mechanism_data()
	local havoc_data = mech_data.havoc_data and Havoc.parse_data(mech_data.havoc_data)
	mod.last_lobby_data = {
		mech = mech_data,
		havoc = havoc_data,
	}
end)
