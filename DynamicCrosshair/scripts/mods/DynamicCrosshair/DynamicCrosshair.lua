local mod = get_mod("DynamicCrosshair")
local Breed = require("scripts/utilities/breed")
local ColorUtilities = require("scripts/utilities/ui/colors")
local Recoil = require("scripts/utilities/recoil")
local Sway = require("scripts/utilities/sway")
local UIWidget = require("scripts/managers/ui/ui_widget")

local OPT_PREFIX_VILLAINS = "^villains_"
local OPT_PREFIX_HEROES = "^heroes_"
local OPT_PREFIX_PROPS = "^props_"
local OPT_PREFIX_GHOST = "^ghost_"

local CROSSHAIR_POSITION_LERP_SPEED = 35
local HIT_MARKER_PREFIX = "hit_"

local MIN_DISTANCE = 1.0
local MAX_DISTANCE = 50.0
local HIT_IDX_DISTANCE = 2
local HIT_IDX_ACTOR = 4

local color_types = {
	villains = {
		mod:get("villains_alpha"),
		mod:get("villains_red"),
		mod:get("villains_green"),
		mod:get("villains_blue"),
	},
	heroes = {
		mod:get("heroes_alpha"),
		mod:get("heroes_red"),
		mod:get("heroes_green"),
		mod:get("heroes_blue"),
	},
	props = {
		mod:get("props_alpha"),
		mod:get("props_red"),
		mod:get("props_green"),
		mod:get("props_blue"),
	},
	ghost = {
		mod:get("ghost_alpha"),
		mod:get("ghost_red"),
		mod:get("ghost_green"),
		mod:get("ghost_blue"),
	},
}

local custom_color_mod = nil
local custom_color = nil

local perspectives_mod = nil
local perspectives_reposition = mod:get("perspectives_reposition")
local perform_repositioning = true

local hooked_crosshair_position = false

local ghost_crosshair_visible = mod:get("show_ghost_crosshair")
local ghost_crosshair_type = nil
local ghost_crosshair_widget = nil
local ghost_crosshair_x = 0
local ghost_crosshair_y = 0
local ghost_range = MAX_DISTANCE
local update_ghost_crosshair = false

local crosshair_ui_hud = nil
local latest_color_type = nil
local latest_range = MAX_DISTANCE

local _rgba_to_idx = function(rgba)
	if rgba == "alpha" then
		return 1
	end
	if rgba == "red" then
		return 2
	end
	if rgba == "green" then
		return 3
	end
	if rgba == "blue" then
		return 4
	end
	return -1
end

local _is_hitmarker = function(part_name)
	return string.sub(part_name, 1, string.len(HIT_MARKER_PREFIX)) == HIT_MARKER_PREFIX
end

local _get_perspective_reposition = function()
	if perspectives_reposition <= 0 then
		return perspectives_reposition == 0
	end
	if perspectives_mod then
		return (perspectives_reposition == 2) == perspectives_mod.is_requesting_third_person()
	end
	return perspectives_reposition == 1
end

local _apply_perspective_reposition = function()
	perform_repositioning = _get_perspective_reposition()
end

local _set_ghost_base_color = function()
	if not ghost_crosshair_widget then
		return
	end
	for part_name, style in pairs(ghost_crosshair_widget.style) do
		ColorUtilities.color_copy(color_types.ghost, style.color)
		style.color[1] = update_ghost_crosshair and not _is_hitmarker(part_name) and color_types.ghost[1] or 0
	end
end

mod.on_setting_changed = function(id)
	local val = mod:get(id)

	if id == "perspectives_reposition" then
		perspectives_reposition = val
		_apply_perspective_reposition()
	elseif id == "show_ghost_crosshair" then
		ghost_crosshair_visible = val
	elseif string.find(id, OPT_PREFIX_VILLAINS) then
		local key = string.sub(id, string.len(OPT_PREFIX_VILLAINS))
		color_types.villains[_rgba_to_idx(key)] = val
	elseif string.find(id, OPT_PREFIX_HEROES) then
		local key = string.sub(id, string.len(OPT_PREFIX_HEROES))
		color_types.heroes[_rgba_to_idx(key)] = val
	elseif string.find(id, OPT_PREFIX_PROPS) then
		local key = string.sub(id, string.len(OPT_PREFIX_PROPS))
		color_types.props[_rgba_to_idx(key)] = val
	elseif string.find(id, OPT_PREFIX_GHOST) then
		local key = string.sub(id, string.len(OPT_PREFIX_GHOST))
		color_types.ghost[_rgba_to_idx(key)] = val
		if key ~= "alpha" then
			_set_ghost_base_color()
		end
	end
end

local _set_custom_color_from_cccmod = function()
	custom_color = custom_color_mod and custom_color_mod:is_enabled() and {
		custom_color_mod:get("crosshair_opacity"),
		custom_color_mod:get("crosshair_r"),
		custom_color_mod:get("crosshair_g"),
		custom_color_mod:get("crosshair_b"),
	}
end

local function _setup_cccmod()
	local is_fresh = not custom_color_mod
	custom_color_mod = get_mod("CustomCrosshairColor")
	if custom_color_mod then
		if is_fresh then
			mod:hook_safe(custom_color_mod, "on_setting_changed", function(id)
				_set_custom_color_from_cccmod()
			end)

			mod:hook_safe(custom_color_mod, "on_enabled", function()
				_setup_cccmod()
			end)

			mod:hook_safe(custom_color_mod, "on_disabled", function()
				_set_custom_color_from_cccmod()
			end)
		end

		custom_color_mod:hook_disable(CLASS.HudElementCrosshair, "_sync_active_crosshair")
		_set_custom_color_from_cccmod()
	end
end

mod.on_all_mods_loaded = function()
	_setup_cccmod()

	perspectives_mod = get_mod("Perspectives")
	if perspectives_mod then
		mod:hook_safe(perspectives_mod, "apply_perspective", function()
			_apply_perspective_reposition()
		end)
	end
	_apply_perspective_reposition()
end

mod:hook_safe(CLASS.HudElementCrosshair, "destroy", function(self)
	crosshair_ui_hud = nil
end)

local _get_shooting_vector = function(player_extensions, weapon_extension)
	player_extensions = player_extensions or (crosshair_ui_hud and crosshair_ui_hud:player_extensions())
	weapon_extension = weapon_extension or (player_extensions and player_extensions.weapon)

	if not player_extensions or not weapon_extension then
		return nil, nil
	end

	local unit_data_extension = player_extensions.unit_data
	local first_person_extention = player_extensions.first_person
	local first_person_unit = first_person_extention:first_person_unit()
	local shoot_rotation = Unit.world_rotation(first_person_unit, 1)
	local movement_state_component = unit_data_extension:read_component("movement_state")
	local locomotion_component = unit_data_extension:read_component("locomotion")
	local inair_state_component = unit_data_extension:read_component("inair_state")

	shoot_rotation = Recoil.apply_weapon_recoil_rotation(
		weapon_extension:recoil_template(),
		unit_data_extension:read_component("recoil"),
		movement_state_component,
		locomotion_component,
		inair_state_component,
		shoot_rotation
	)

	shoot_rotation = Sway.apply_sway_rotation(
		weapon_extension:sway_template(),
		unit_data_extension:read_component("sway"),
		shoot_rotation
	)

	return Unit.world_position(first_person_unit, 1), Quaternion.forward(shoot_rotation)
end

local _crosshair_raycast = function(physics_world, shoot_position, shoot_direction)
	return PhysicsWorld.raycast(
		physics_world,
		shoot_position,
		shoot_direction,
		MAX_DISTANCE,
		"all",
		"collision_filter",
		"filter_debug_unit_selector"
	)
end

mod:hook_safe(CLASS.PlayerUnitFirstPersonExtension, "fixed_update", function(self, ...)
	local static_range = MAX_DISTANCE
	local range = MAX_DISTANCE
	local color_type = nil

	local shoot_position, shoot_direction = _get_shooting_vector()
	local physics_world = self._footstep_context and self._footstep_context.physics_world
	if shoot_position and shoot_direction and physics_world then
		local hits = _crosshair_raycast(physics_world, shoot_position, shoot_direction)
		if hits then
			local Actor_unit = Actor.unit
			local Actor_is_static = Actor.is_static
			local closest_hit = nil
			local num_hits = #hits
			for i = 1, num_hits do
				local hit = hits[i]
				local distance = hit[HIT_IDX_DISTANCE]
				local hit_actor = hit[HIT_IDX_ACTOR]
				local unit = Actor_unit(hit_actor)
				if unit and unit ~= self._unit and distance > MIN_DISTANCE then
					closest_hit = distance < range and hit or closest_hit
					range = distance < range and distance or range
					static_range = Actor_is_static(hit_actor) and distance < static_range and distance or static_range
				end
			end

			if closest_hit then
				local unit = Actor_unit(closest_hit[HIT_IDX_ACTOR])
				local health_extension = ScriptUnit.has_extension(unit, "health_system")
				if health_extension and health_extension:is_alive() then
					local target_unit_data_extension = ScriptUnit.extension(unit, "unit_data_system")
					local breed = target_unit_data_extension and target_unit_data_extension:breed()

					color_type = breed and (
						Breed.is_minion(breed) and "villains"
						or Breed.is_player(breed) and "heroes"
						or Breed.is_prop(breed) and "props"
					) or nil
				end
			end
		end
	end

	update_ghost_crosshair = color_type and ghost_crosshair_visible and perform_repositioning or false
	ghost_range = update_ghost_crosshair and static_range or MAX_DISTANCE
	latest_range = range
	latest_color_type = color_type
end)

local _get_crosshair_position = function(dt, ui_renderer, pivot_position, prev_x, prev_y, range, skip_lerp)
	local target_x = 0
	local target_y = 0
	local ui_renderer_scale = ui_renderer.scale
	local player_extensions = crosshair_ui_hud and crosshair_ui_hud:player_extensions()
	local weapon_extension = player_extensions and player_extensions.weapon
	local player_camera = crosshair_ui_hud and crosshair_ui_hud:player_camera()

	if weapon_extension and player_camera then
		local shoot_position, shoot_direction = _get_shooting_vector(player_extensions, weapon_extension)
		local screen_aim_position = Camera.world_to_screen(player_camera, shoot_position + shoot_direction * range)
		target_x = screen_aim_position.x - pivot_position[1]
		target_y = screen_aim_position.y - pivot_position[2]
	end

	local ui_inv_scale = ui_renderer.inverse_scale
	local lerp_t = math.min(CROSSHAIR_POSITION_LERP_SPEED * dt, 1)
	local x = (skip_lerp and target_x
		or math.lerp(prev_x * ui_renderer_scale, target_x, lerp_t)) * ui_inv_scale
	local y = (skip_lerp and target_y
		or math.lerp(prev_y * ui_renderer_scale, target_y, lerp_t)) * ui_inv_scale

	return x, y
end

mod:hook_require("scripts/ui/utilities/crosshair", function(Crosshair)
	if hooked_crosshair_position then
		return
	end
	hooked_crosshair_position = true

	mod:hook(Crosshair, "position", function(func, dt, t, ui_hud, ui_renderer, current_x, current_y, pivot_position)
		if not crosshair_ui_hud then
			crosshair_ui_hud = ui_hud
		end

		ghost_crosshair_x, ghost_crosshair_y = _get_crosshair_position(
			dt,
			ui_renderer,
			pivot_position,
			ghost_crosshair_x,
			ghost_crosshair_y,
			ghost_range,
			true
		)

		return _get_crosshair_position(
			dt,
			ui_renderer,
			pivot_position,
			current_x,
			current_y,
			perform_repositioning and latest_range or MAX_DISTANCE,
			ghost_crosshair_visible and perform_repositioning and not latest_color_type
		)
	end)
end)

mod:hook_safe(CLASS.HudElementCrosshair, "update", function(self, dt, t, ui_renderer, render_settings, input_service)
	local widget = self._widget
	local base_def = self._crosshair_widget_definitions[self._crosshair_type]
	if update_ghost_crosshair and ghost_crosshair_type ~= self._crosshair_type then
		if ghost_crosshair_widget and ghost_crosshair_type then
			self:_unregister_widget_name("ghost_" .. ghost_crosshair_type)
			ghost_crosshair_widget = nil
		end

		local widget_definition = self._crosshair_widget_definitions[self._crosshair_type]
		if widget_definition then
			ghost_crosshair_widget = self:_create_widget("ghost_" .. self._crosshair_type, widget_definition)
			local template = self._crosshair_templates[self._crosshair_type]
			local on_enter = template.on_enter
			if on_enter then
				on_enter(ghost_crosshair_widget, template)
			end
			_set_ghost_base_color()
		end

		ghost_crosshair_type = self._crosshair_type
	end

	if widget and base_def then
		local color = latest_color_type and color_types[latest_color_type] or custom_color
		for part_name, style in pairs(widget.style) do
			if not _is_hitmarker(part_name) then
				ColorUtilities.color_copy(color or base_def.style[part_name].color, style.color)
			end

			local ghost_style = ghost_crosshair_widget and ghost_crosshair_widget.style
				and ghost_crosshair_widget.style[part_name]
			if ghost_style then
				ghost_style.color[1] = update_ghost_crosshair and not _is_hitmarker(part_name) and color_types.ghost[1]
					or 0
				if update_ghost_crosshair then
					ghost_style.angle = style.angle
					ghost_style.size = style.size
					ghost_style.offset = style.offset
					ghost_style.uvs = style.uvs
					ghost_style.pivot = style.pivot
				end
			end
		end
	end

	if ghost_crosshair_type and update_ghost_crosshair then
		local template = self._crosshair_templates[ghost_crosshair_type]
		local update_function = template and template.update_function

		if update_function then
			update_function(self, ui_renderer, self._widget, template, self:_crosshair_settings(), dt, t)
		end
	end
end)

mod:hook_safe(CLASS.HudElementCrosshair, "_draw_widgets",
	function(self, dt, t, input_service, ui_renderer, ...)
		if ghost_crosshair_widget then
			local widget_offset = ghost_crosshair_widget.offset
			widget_offset[1] = ghost_crosshair_x
			widget_offset[2] = ghost_crosshair_y
			widget_offset[3] = -10

			UIWidget.draw(ghost_crosshair_widget, ui_renderer)
		end
	end)
