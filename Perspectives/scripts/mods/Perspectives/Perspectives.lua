local mod = get_mod("Perspectives")
local CameraTransitionTemplates = require("scripts/settings/camera/camera_transition_templates")
local PlayerUnitStatus = require("scripts/utilities/attack/player_unit_status")

mod:io_dofile("Perspectives/scripts/mods/Perspectives/Utils")
mod:io_dofile("Perspectives/scripts/mods/Perspectives/CameraTree")

local OPT_PREFIX_AUTOSWITCH = "^autoswitch_"
local ZOOM_SUFFIX = "_zoom"

local aim_selection = mod:get("aim_mode")
local nonaim_selection = mod:get("nonaim_mode")
local cycle_includes_center = mod:get("cycle_includes_center")
local center_to_1p_human = mod:get("center_to_1p_human")
local center_to_1p_ogryn = mod:get("center_to_1p_ogryn")

local desire_3p = false
local center_aim_override = false
local switch_stack = {}
local autoswitch_edges = {}
local autoswitch_events = {}

local current_wield_slot = nil
local use_3p_freelook_node = false
local holding_primary = false
local holding_secondary = false
local is_spectating = false
local is_blocking_slabshield = false
local is_in_hub = false
local xhair_fallback = nil

local _get_followed_unit = function()
	local camera_handler = mod.get_camera_handler()
	return camera_handler and camera_handler:camera_follow_unit()
end

local _get_next_viewpoint = function(previous)
	if previous == "pspv_right" then
		return "pspv_left"
	end
	if previous == "pspv_left" and cycle_includes_center then
		return "pspv_center"
	end
	return "pspv_right"
end
local current_viewpoint = _get_next_viewpoint()

local _idx_to_viewpoint = function(idx)
	if idx == 1 then
		return "pspv_center"
	end
	if idx == 2 then
		return "pspv_right"
	end
	if idx == 3 then
		return "pspv_left"
	end
	return current_viewpoint
end

local _get_aim_node = function()
	return _idx_to_viewpoint(aim_selection) .. ZOOM_SUFFIX
end
local aim_node = _get_aim_node()

local _get_nonaim_node = function()
	return _idx_to_viewpoint(nonaim_selection)
end
local nonaim_node = _get_nonaim_node()

mod.kb_cycle_shoulder = function()
	if not mod.is_cursor_active() then
		current_viewpoint = _get_next_viewpoint(current_viewpoint)
		aim_node = _get_aim_node()
		nonaim_node = _get_nonaim_node()
	end
end

mod.on_all_mods_loaded = function()
	local freeflight_mod = get_mod("camera_freeflight")
	if freeflight_mod then
		mod:hook(freeflight_mod, "set_3p", function(func, self, enabled)
			func(self, enabled or mod.is_requesting_third_person())
		end)
	end

	local lookaround_mod = get_mod("LookAround")
	if lookaround_mod then
		mod:hook_safe(lookaround_mod, "on_freelook_changed", function(value)
			use_3p_freelook_node = value and mod:get("use_lookaround_node")
		end)
	end
end

local _apply_center_aim_override = function(override)
	if center_aim_override ~= override then
		center_aim_override = override
		mod.apply_perspective()
	end
end

mod.is_requesting_third_person = function()
	if center_aim_override then
		return false
	end

	local stack_size = #switch_stack
	if stack_size > 0 then
		return switch_stack[stack_size].to_3p
	end

	return desire_3p
end

mod.apply_perspective = function()
	local unit = _get_followed_unit()
	if unit then
		local ext = ScriptUnit.has_extension(unit, "first_person_system")
		if ext then
			ext._force_third_person_mode = mod.is_requesting_third_person()
		end
	end
end

mod.find_reason = function(reason)
	for i = #switch_stack, 1, -1 do
		if switch_stack[i].reason == reason then
			return i
		end
	end
	return -1
end

mod.clear_reason = function(reason)
	local idx = mod.find_reason(reason)
	if idx > 0 then
		local last = idx == #switch_stack
		table.remove(switch_stack, idx)
		if last then
			mod.apply_perspective()
		end
	end
end

mod.autoswitch = function(reason, to_3p, stack)
	local at = mod.find_reason(reason)
	if stack then
		if at > 0 then
			local si = switch_stack[at]
			si.to_3p = to_3p

			local last = at == #switch_stack
			if not last then
				table.remove(switch_stack, at)
				switch_stack[#switch_stack + 1] = si
			end
		else
			switch_stack[#switch_stack + 1] = {
				reason = reason,
				to_3p = to_3p,
			}
		end
		mod.apply_perspective()
	else
		mod.set_third_person(to_3p)
	end
end

local _autoswitch_from_event = function(category, event, condition)
	if is_spectating and category ~= "spectate" then
		return
	end

	local auto_mode = autoswitch_events[event]
	local clear = event == nil or (condition ~= nil and not condition) or auto_mode == 0
	local result = clear and 0 or auto_mode
	if autoswitch_edges[category] ~= result then
		autoswitch_edges[category] = result
		if clear then
			mod.clear_reason(category)
		elseif auto_mode then
			mod.autoswitch(category, auto_mode == 2 or auto_mode == -2, auto_mode > 0)
		end
	end
end

mod.on_setting_changed = function(id)
	local val = mod:get(id)

	if id == "xhair_fallback" then
		xhair_fallback = val
	elseif id == "cycle_includes_center" then
		cycle_includes_center = val
	elseif id == "center_to_1p_human" then
		center_to_1p_human = val
	elseif id == "center_to_1p_ogryn" then
		center_to_1p_ogryn = val
	elseif id == "aim_mode" then
		aim_selection = val
		aim_node = _get_aim_node()
	elseif id == "nonaim_mode" then
		nonaim_selection = val
		nonaim_node = _get_nonaim_node()
	elseif id == "perspective_transition_time" then
		CameraTransitionTemplates.to_third_person.position.duration = val
		CameraTransitionTemplates.to_first_person.position.duration = val
	elseif id == "custom_distance"
		or id == "custom_offset"
		or id == "custom_distance_zoom"
		or id == "custom_offset_zoom"
		or id == "custom_distance_ogryn"
		or id == "custom_offset_ogryn"
	then
		mod.apply_custom_viewpoint()
	elseif string.find(id, OPT_PREFIX_AUTOSWITCH) then
		local key = string.sub(id, string.len(OPT_PREFIX_AUTOSWITCH))
		autoswitch_events[key] = val
	end
end
mod.on_setting_changed("perspective_transition_time")
mod.on_setting_changed("allow_switching")
mod.on_setting_changed("xhair_fallback")
mod.on_setting_changed("autoswitch_spectate")
mod.on_setting_changed("autoswitch_slot_device")
mod.on_setting_changed("autoswitch_slot_primary")
mod.on_setting_changed("autoswitch_slot_secondary")
mod.on_setting_changed("autoswitch_slot_grenade_ability")
mod.on_setting_changed("autoswitch_slot_pocketable")
mod.on_setting_changed("autoswitch_slot_pocketable_small")
mod.on_setting_changed("autoswitch_slot_luggable")
mod.on_setting_changed("autoswitch_slot_unarmed")
mod.on_setting_changed("autoswitch_sprint")
mod.on_setting_changed("autoswitch_lunge_ogryn")
mod.on_setting_changed("autoswitch_lunge_human")
mod.on_setting_changed("autoswitch_act2_primary")
mod.on_setting_changed("autoswitch_act2_secondary")
mod.on_setting_changed("autoswitch_slab_block")
mod.apply_custom_viewpoint()

mod.set_third_person = function(to_3p)
	table.clear(switch_stack)
	desire_3p = to_3p
	mod.apply_perspective()
end

mod.toggle_third_person = function()
	mod.set_third_person(not mod.is_requesting_third_person())
end

mod.kb_toggle_third_person = function()
	if not mod.is_cursor_active() then
		mod.toggle_third_person()
	end
end

mod:hook_safe(CLASS.ActionBlock, "start", function(self, action_settings)
	-- self._weapon_template is set in ActionWeaponBase.init from action_params.weapon
	if action_settings.kind ~= "block_windup" and action_settings.weapon_special then
		local weapon_template = self._weapon_template
		-- if action_settings.weapon_special is true then it's planting, not just blocking
		if weapon_template and weapon_template.name == "ogryn_powermaul_slabshield_p1_m1" then
			is_blocking_slabshield = true
			_autoswitch_from_event("slab_block", "slab_block", true)
		end
	end
end)

mod:hook_safe(CLASS.ActionBlock, "finish", function()
	if is_blocking_slabshield then
		is_blocking_slabshield = false
		_autoswitch_from_event("slab_block", "slab_block", false)
	end
end)

mod:hook(CLASS.PlayerUnitWeaponExtension, "_fill_action_params", function(func, self, weapon, player_unit, wielded_slot)
	if self._player == Managers.player:local_player(1) and current_wield_slot ~= wielded_slot then
		current_wield_slot = wielded_slot
		_autoswitch_from_event("slot", wielded_slot)
		_autoswitch_from_event("act2", nil)
		holding_primary = wielded_slot == "slot_primary"
		holding_secondary = wielded_slot == "slot_secondary"
	end
	return func(self, weapon, player_unit, wielded_slot)
end)

local _input_action_hook = function(func, self, action_name)
	local val = func(self, action_name)
	if action_name == "action_two_hold" then
		if holding_primary then
			_autoswitch_from_event("act2", "act2_primary", val)
		elseif holding_secondary then
			_autoswitch_from_event("act2", "act2_secondary", val)
		end
	end
	return val
end
mod:hook(CLASS.InputService, "_get", _input_action_hook)
mod:hook(CLASS.InputService, "_get_simulate", _input_action_hook)

mod:hook(CLASS.MissionManager, "force_third_person_mode", function(func, self)
	local mode = mod:get("default_perspective_mode")

	local request_3p = func(self)
	if mode == -1 then
		request_3p = not request_3p
	elseif mode == 1 then
		request_3p = false
	elseif mode == 2 then
		request_3p = true
	end

	mod.set_third_person(request_3p)
	return request_3p
end)

local _should_aim_to_1p = function(is_aiming, is_ogryn)
	if not is_aiming then
		return false
	end
	if aim_selection == -1 then
		return true
	end

	if aim_selection == 0 and current_viewpoint == "pspv_center" then
		if is_ogryn then
			return center_to_1p_ogryn
		end
		return center_to_1p_human
	end
	return false
end

local NODE_IGNORE_SCALED_TRANSFORM_OFFSETS = {
	consumed = true
}
local NODE_OBJECT_NAMES = {
	consumed = "j_hips"
}
mod:hook(CLASS.PlayerUnitCameraExtension, "_evaluate_camera_tree", function(func, self)
	if self._unit ~= mod.get_player_unit() then
		func(self)
		return
	end
	-- modified from scripts/extension_systems/camera/player_unit_camera_extension
	local wants_first_person_camera = self._first_person_extension:wants_first_person_camera()
	local character_state_component = self._character_state_component
	local assisted_state_input_component = self._assisted_state_input_component
	local sprint_character_state_component = self._sprint_character_state_component
	local disabling_type = self._disabled_character_state_component.disabling_type
	local is_ledge_hanging = PlayerUnitStatus.is_ledge_hanging(character_state_component)
	local is_assisted = PlayerUnitStatus.is_assisted(assisted_state_input_component)
	local is_pounced = disabling_type == "pounced"
	local is_netted = disabling_type == "netted"
	local is_warp_grabbed = disabling_type == "warp_grabbed"
	local is_mutant_charged = disabling_type == "mutant_charged"
	local is_grabbed = disabling_type == "grabbed"
	local is_consumed = disabling_type == "consumed"
	local alternate_fire_is_active = self._alternate_fire_component.is_active
	local tree, node = nil, nil

	local is_ogryn = self._breed.name == "ogryn"
	_apply_center_aim_override(_should_aim_to_1p(alternate_fire_is_active, is_ogryn))

	local wants_sprint_camera = sprint_character_state_component.wants_sprint_camera
	local is_lunging = self._lunge_character_state_component.is_lunging
	if wants_sprint_camera then
		_autoswitch_from_event("movt", "sprint")
	elseif is_lunging then
		if is_ogryn then
			_autoswitch_from_event("movt", "lunge_ogryn")
		else
			_autoswitch_from_event("movt", "lunge_human")
		end
	else
		_autoswitch_from_event("movt", nil)
	end

	if wants_first_person_camera then
		local sprint_overtime = sprint_character_state_component.sprint_overtime
		local have_sprint_over_time = sprint_overtime and sprint_overtime > 0

		if is_assisted then
			node = "first_person_assisted"
		elseif alternate_fire_is_active then
			node = "aim_down_sight"
		elseif wants_sprint_camera and have_sprint_over_time then
			node = "sprint_overtime"
		elseif wants_sprint_camera then
			node = "sprint"
		elseif is_lunging then
			node = "lunge"
		else
			node = "first_person"
		end

		tree = "first_person"
	elseif self._use_third_person_hub_camera then
		tree = "third_person_hub"

		if is_ogryn then
			node = "third_person_ogryn"
		else
			node = "third_person_human"
		end
	else
		local is_disabled, requires_help = PlayerUnitStatus.is_disabled(character_state_component)
		local is_hogtied = PlayerUnitStatus.is_hogtied(character_state_component)

		if is_hogtied then
			node = "hogtied"
		elseif is_ledge_hanging then
			node = "ledge_hanging"
		elseif is_pounced or is_netted or is_warp_grabbed or is_mutant_charged or is_grabbed then
			node = "pounced"
		elseif is_consumed then
			node = "consumed"
		elseif is_disabled and requires_help then
			node = "disabled"
		else
			if mod.is_requesting_third_person() then
				if use_3p_freelook_node then
					node = "pspv_lookaround"
				elseif alternate_fire_is_active then
					node = aim_node
				else
					node = nonaim_node
				end

				if is_ogryn then
					node = node .. "_ogryn"
				end
			else
				node = "third_person"
			end
		end

		tree = "third_person"
	end

	local camera_tree_component = self._camera_tree_component
	camera_tree_component.tree = tree
	camera_tree_component.node = node
	self._tree = tree
	self._node = node
	local object_name = NODE_OBJECT_NAMES[node]
	local object = nil

	if object_name then
		object = Unit.node(self._unit, object_name)
	end

	self._object = object
	local ignore_offset = NODE_IGNORE_SCALED_TRANSFORM_OFFSETS[node]

	if self._ignore_offset ~= ignore_offset then
		local player_unit_spawn_manager = Managers.state.player_unit_spawn
		local player = player_unit_spawn_manager:owner(self._unit)

		if player:is_human_controlled() then
			local viewport_name = player.viewport_name

			if viewport_name then
				Managers.state.camera:set_variable(viewport_name, "ignore_offset", ignore_offset)
			end
		end
	end

	self._ignore_offset = ignore_offset
end)

mod:hook(CLASS.PlayerHuskCameraExtension, "camera_tree_node", function(func, self)
	local tree, node, object = func(self)
	if mod.is_requesting_third_person() then
		tree = "third_person"
		node = nonaim_node
	else
		tree = "first_person"
		node = "first_person"
	end
	return tree, node, object
end)

mod:hook(CLASS.CameraHandler, "_next_follow_unit", function(func, self, except_unit)
	if not self._side_id and self._side_system then
		local side = self._side_system:get_side_from_name("heroes")
		self._side_id = side and side.side_id
	end
	return func(self, except_unit)
end)

mod:hook_safe(CLASS.CameraHandler, "_switch_follow_target", function(self, new_unit)
	if self._player then
		is_spectating = new_unit ~= self._player.player_unit
		_autoswitch_from_event("spectate", "spectate", is_spectating)
	end
	mod.apply_perspective()
end)

mod:hook(CLASS.PlayerHuskFirstPersonExtension, "_update_first_person_mode", function(func, self, t)
	if self._is_first_person_spectated then
		local in_1p = not mod.is_requesting_third_person()
		return in_1p, in_1p
	end
	return func(self, t)
end)

mod:hook_safe(CLASS.GameModeManager, "init", function(self, game_mode_context, game_mode_name, ...)
	is_in_hub = game_mode_name == "hub"
end)

mod:hook(CLASS.HudElementCrosshair, "_get_current_crosshair_type", function(func, self, crosshair_settings)
	local type = func(self, crosshair_settings)
	return crosshair_settings and xhair_fallback ~= "none"
		and (type == "none" or type == "ironsight")
		and not is_in_hub and mod.is_requesting_third_person()
		and xhair_fallback or type
end)
