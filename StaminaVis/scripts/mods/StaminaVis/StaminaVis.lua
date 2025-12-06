local mod = get_mod("StaminaVis")

local FixedFrame = require("scripts/utilities/fixed_frame")

local vanish_timeout = 0.0
local vanish_delay = mod:get("vanish_delay")
local vanish_speed = mod:get("vanish_speed")

local appear_timeout = 0.0
local appear_delay = mod:get("appear_delay")
local appear_speed = mod:get("appear_speed")

local vis_behavior = mod:get("vis_behavior")

local prev_fade_instruction = nil
local current_alpha = 0

local stam_wants_vis = false
local dodge_wants_vis = false

mod.on_setting_changed = function(id)
	if id == "vis_behavior" then
		vis_behavior = mod:get(id)
	elseif id == "vanish_speed" then
		vanish_speed = mod:get(id)
	elseif id == "appear_speed" then
		appear_speed = mod:get(id)
	elseif id == "vanish_delay" then
		vanish_timeout = 0.0
		vanish_delay = mod:get(id)
	elseif id == "appear_delay" then
		appear_timeout = 0.0
		appear_delay = mod:get(id)
	end
end

mod:hook(CLASS.HudElementStamina, "_update_visibility", function(func, self, dt)
	if vis_behavior > 0 then
		current_alpha = 1.0
	elseif vis_behavior < 0 then
		current_alpha = 0.0
	else
		-- check if stamina is requesting visibility
		stam_wants_vis = false

		local player_extensions = self._parent:player_extensions()
		if player_extensions then
			local player_unit_data = player_extensions.unit_data
			if player_unit_data then
				local block_component = player_unit_data:read_component("block")
				local sprint_component = player_unit_data:read_component("sprint_character_state")
				local stamina_component = player_unit_data:read_component("stamina")

				stam_wants_vis = block_component and block_component.is_blocking
					or sprint_component and sprint_component.is_sprinting
					or stamina_component and stamina_component.current_fraction < 1
			end
		end

		-- actually perform alpha math for both stamina and dodge
		local draw = stam_wants_vis or dodge_wants_vis
		if draw ~= prev_fade_instruction then
			appear_timeout = draw and appear_delay or 0
			vanish_timeout = draw and 0 or vanish_delay
			prev_fade_instruction = draw
		end

		if vanish_timeout > 0.0 then
			vanish_timeout = vanish_timeout - dt
		end
		if appear_timeout > 0.0 then
			appear_timeout = appear_timeout - dt
		end

		if vanish_timeout <= 0.0 and appear_timeout > 0.0 then
			draw = false
		elseif appear_timeout <= 0.0 and vanish_timeout > 0.0 then
			draw = true
		end
		current_alpha = draw
			and (appear_speed > 0 and math.min(current_alpha + dt * appear_speed, 1) or 1)
			or (vanish_speed > 0 and math.max(current_alpha - dt * vanish_speed, 0) or 0)
	end
end)

mod:hook(CLASS.HudElementDodgeCounter, "_update_visibility", function(func, self, dt)
	if vis_behavior == 0 then
		-- check if dodge is requesting visibility
		local consecutive_dodges_performed = self._consecutive_dodges_performed
		local consecutive_dodges_cooldown = self._consecutive_dodges_cooldown
		local fixed_t = FixedFrame.get_latest_fixed_time()
		dodge_wants_vis = consecutive_dodges_performed > 0 or fixed_t <= consecutive_dodges_cooldown + 1
	end
end)

local _apply_alpha = function(func, self, dt, t, input_service, ui_renderer, render_settings)
	self._alpha_multiplier = current_alpha * (render_settings.alpha_multiplier or 1)
	func(self, dt, t, input_service, ui_renderer, render_settings)
end
mod:hook(CLASS.HudElementStamina, "_draw_widgets", _apply_alpha)
mod:hook(CLASS.HudElementDodgeCounter, "_draw_widgets", _apply_alpha)
