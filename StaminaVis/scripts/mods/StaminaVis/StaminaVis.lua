local mod = get_mod("StaminaVis")

local vanish_timeout = 0.0
local vanish_delay = mod:get("vanish_delay")
local vanish_speed = mod:get("vanish_speed")

local appear_timeout = 0.0
local appear_delay = mod:get("appear_delay")
local appear_speed = mod:get("appear_speed")

local vis_behavior = mod:get("vis_behavior")

local prev_instruction = nil

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

mod:hook("HudElementBlocking", "_update_visibility", function(func, self, dt)
    if vis_behavior > 0 then
        self._alpha_multiplier = 1.0
    elseif vis_behavior < 0 then
        self._alpha_multiplier = 0.0
    else
        -- modified from "scripts/ui/hud/elements/blocking/hud_element_blocking"
        local draw = false
        local parent = self._parent
        local player_extensions = parent:player_extensions()

        if player_extensions then
            local player_unit_data = player_extensions.unit_data

            if player_unit_data then
                local block_component = player_unit_data:read_component("block")
                local sprint_component = player_unit_data:read_component("sprint_character_state")
                local stamina_component = player_unit_data:read_component("stamina")

                if block_component and block_component.is_blocking or sprint_component and sprint_component.is_sprinting or stamina_component and stamina_component.current_fraction < 1 then
                    draw = true
                end
            end
        end

        if draw ~= prev_instruction then
            if draw then
                appear_timeout = appear_delay
                vanish_timeout = 0.0
            else
                vanish_timeout = vanish_delay
                appear_timeout = 0.0
            end
        end
        prev_instruction = draw

        if vanish_timeout > 0.0 then
            vanish_timeout = vanish_timeout - dt
        end
        if appear_timeout > 0.0 then
            appear_timeout = appear_timeout - dt
        end

        local appear = draw
        if vanish_timeout <= 0.0 and appear_timeout > 0.0 then
            appear = false
        elseif appear_timeout <= 0.0 and vanish_timeout > 0.0 then
            appear = true
        end

        local alpha_multiplier = self._alpha_multiplier or 0.0
        if appear then
            if appear_speed > 0.0 then
                alpha_multiplier = math.min(alpha_multiplier + dt * appear_speed, 1.0)
            else
                alpha_multiplier = 1.0
            end
        else
            if vanish_speed > 0.0 then
                alpha_multiplier = math.max(alpha_multiplier - dt * vanish_speed, 0.0)
            else
                alpha_multiplier = 0.0
            end
        end
        self._alpha_multiplier = alpha_multiplier
    end
end)
