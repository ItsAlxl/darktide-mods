local mod = get_mod("ToggleAltFire")

local UNTOGGLE_STATES = {
	ledge_hanging = true,
	warp_grabbed = true,
	dead = true,
	hogtied = true,
	grabbed = true,
	catapulted = true,
	knocked_down = true,
	consumed = true,
	netted = true,
	mutant_charged = true,
	pounced = true,
	stunned = true,
	interacting = true,
}
local MELEE_EXTRAS = {
	"push",
	"action_push",
	"action_normal_push",
	"action_psyker_push",
	"action_stab_start",
	"action_slash_start",
	"action_bash_start",
	"action_pistol_whip",
}

local untoggle_actions = {
	action_shoot_braced = mod:get("action_shoot_braced"),
	action_shoot_charged = mod:get("action_shoot_charged"),
	action_vent = mod:get("action_vent"),
	action_sprint = false,
	action_reload = mod:get("action_reload"),
	action_start_reload = mod:get("action_start_reload"),
	action_lunge = mod:get("action_lunge"),
}
for _, act in pairs(MELEE_EXTRAS) do
	untoggle_actions[act] = mod:get("action_melee_extra")
end

mod.on_setting_changed = function(id)
	local val = mod:get(id)
	if id == "action_melee_extra" then
		for _, act in pairs(MELEE_EXTRAS) do
			untoggle_actions[act] = val
		end
	elseif untoggle_actions[id] ~= nil then
		untoggle_actions[id] = val
	end
end

local last_seen_weapon = nil
local perform_toggle = false
local toggle_state = false
local prev_act = false
local request_sprint = false

local function _set_toggleable(t)
	perform_toggle = t
	toggle_state = false
	prev_act = false
end

local function _is_toggleable_blitz(template)
	untoggle_actions.action_sprint = mod:get("_sprint_blitz")
	return mod:get(template.name)
end

local function _is_toggleable_weapon(template)
	local keywords = template.keywords
	local is_staff = false
	for i = 1, #keywords do
		if keywords[i] == "force_staff" then
			is_staff = true
		end
	end
	if is_staff then
		untoggle_actions.action_sprint = mod:get("_sprint_staff")
	else
		untoggle_actions.action_sprint = mod:get("_sprint_base")
	end

	return mod:get(mod.weapon_to_family(template.name))
end

mod:hook(CLASS.PlayerUnitWeaponExtension, "_fill_action_params", function(func, self, weapon, player_unit, wielded_slot)
	if last_seen_weapon ~= weapon and self._player == Managers.player:local_player(1) then
		last_seen_weapon = weapon

		local template = weapon.weapon_template
		_set_toggleable(wielded_slot == "slot_secondary" and _is_toggleable_weapon(template)
			or wielded_slot == "slot_grenade_ability" and _is_toggleable_blitz(template))
	end
	return func(self, weapon, player_unit, wielded_slot)
end)

local _input_action_hook = function(func, self, action_name)
	local val = func(self, action_name)
	if perform_toggle then
		if action_name == "action_two_hold" then
			local fresh = not prev_act and val
			prev_act = val
			if fresh then
				toggle_state = not toggle_state
			end
			return toggle_state
		end

		if toggle_state and val and untoggle_actions.action_sprint and (action_name == "sprint" or action_name == "sprinting") then
			toggle_state = false
			request_sprint = true
		end
	end
	return val
end
mod:hook(CLASS.InputService, "_get", _input_action_hook)
mod:hook(CLASS.InputService, "_get_simulate", _input_action_hook)

mod:hook_safe("CharacterStateMachine", "_change_state", function(self, unit, dt, t, next_state, ...)
	if perform_toggle then
		if UNTOGGLE_STATES[next_state] or (untoggle_actions.action_lunge and next_state == "lunging") then
			toggle_state = false
		end
	end
end)

mod:hook_safe("ActionHandler", "start_action", function(self, id, action_objects, action_name, ...)
	if perform_toggle then
		if untoggle_actions[action_name] then
			toggle_state = false
		end
	end
end)

mod:hook_require("scripts/extension_systems/character_state_machine/character_states/utilities/sprint",
	function(instance)
		mod:hook(instance, "sprint_input", function(func, input_source, is_sprinting, sprint_requires_press_to_interrupt)
			if is_sprinting then
				request_sprint = false
			elseif request_sprint then
				return true
			end
			return func(input_source, is_sprinting, sprint_requires_press_to_interrupt)
		end)
	end)
