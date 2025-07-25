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

local toggleable_weapon_categories = {
	autogun = mod:get("autogun"),
	autopistol = mod:get("autopistol"),
	lasgun = mod:get("lasgun"),
	laspistol = mod:get("laspistol"),
	stub_rifle = mod:get("stub_rifle"),
	stub_pistol = mod:get("stub_pistol"),
	shotgun = mod:get("shotgun"),
	rippergun = mod:get("rippergun"),
	bolter = mod:get("bolter"),
	boltpistol = mod:get("boltpistol"),
	shotpistol_shield = mod:get("shotpistol_shield"),
	heavystubber = mod:get("heavystubber"),
	grenadier_gauntlet = mod:get("grenadier_gauntlet"),
	shotgun_grenade = mod:get("shotgun_grenade"),
	plasma_rifle = mod:get("plasma_rifle"),
	flamer = mod:get("flamer"),
	force_staff = mod:get("force_staff")
}

local toggleable_blitzes = {
	psyker_smite = mod:get("psyker_smite"),
	psyker_chain_lightning = mod:get("psyker_chain_lightning"),
	psyker_throwing_knives = mod:get("psyker_throwing_knives"),
	frag_grenade = mod:get("frag_grenade"),
	krak_grenade = mod:get("krak_grenade"),
	smoke_grenade = mod:get("smoke_grenade"),
	shock_grenade = mod:get("shock_grenade"),
	fire_grenade = mod:get("fire_grenade"),
	zealot_throwing_knives = mod:get("zealot_throwing_knives"),
	ogryn_grenade_box = mod:get("ogryn_grenade_box"),
	ogryn_grenade_box_cluster = mod:get("ogryn_grenade_box_cluster"),
	ogryn_grenade_frag = mod:get("ogryn_grenade_frag"),
	ogryn_grenade_friend_rock = mod:get("ogryn_grenade_friend_rock"),
}

mod.on_setting_changed = function(id)
	local val = mod:get(id)
	if toggleable_weapon_categories[id] ~= nil then
		toggleable_weapon_categories[id] = val
	end

	if id == "action_melee_extra" then
		for _, act in pairs(MELEE_EXTRAS) do
			untoggle_actions[act] = val
		end
	elseif untoggle_actions[id] ~= nil then
		untoggle_actions[id] = val
	end
end

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
	return toggleable_blitzes[template.name]
end

local function _is_toggleable_weapon(template)
	for _, k in pairs(template.keywords) do
		if toggleable_weapon_categories[k] then
			if k == "force_staff" then
				untoggle_actions.action_sprint = mod:get("_sprint_staff")
			else
				untoggle_actions.action_sprint = mod:get("_sprint_base")
			end
			return true
		end
	end
	return false
end

mod:hook_safe("PlayerUnitWeaponExtension", "on_slot_wielded", function(self, slot_name, ...)
	local template = self._weapons[slot_name].weapon_template
	_set_toggleable(
		slot_name == "slot_secondary" and _is_toggleable_weapon(template)
		or slot_name == "slot_grenade_ability" and _is_toggleable_blitz(template)
	)
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

mod:hook_require("scripts/extension_systems/character_state_machine/character_states/utilities/sprint", function(instance)
	mod:hook(instance, "sprint_input", function(func, input_source, is_sprinting, sprint_requires_press_to_interrupt)
		if is_sprinting then
			request_sprint = false
		elseif request_sprint then
			return true
		end
		return func(input_source, is_sprinting, sprint_requires_press_to_interrupt)
	end)
end)
