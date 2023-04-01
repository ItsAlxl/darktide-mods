local mod = get_mod("StaminaVis")

local COMP_BASE_PREFIX = "^comp_base_"
local COMP_MELEE_PREFIX = "^comp_melee_"

local vanish_timeout = 0.0
local vanish_delay = mod:get("vanish_delay")
local vanish_speed = mod:get("vanish_speed")

local appear_timeout = 0.0
local appear_delay = mod:get("appear_delay")
local appear_speed = mod:get("appear_speed")

local vis_behavior = mod:get("vis_behavior")

local base_components = {
    lbl = mod:get("comp_base_lbl"),
    perc = mod:get("comp_base_perc"),
    bar = mod:get("comp_base_bar"),
    bracket = mod:get("comp_base_bracket"),
    flip = mod:get("comp_base_flip"),
}
local melee_components = {
    lbl = mod:get("comp_melee_lbl"),
    perc = mod:get("comp_melee_perc"),
    bar = mod:get("comp_melee_bar"),
    bracket = mod:get("comp_melee_bracket"),
    flip = mod:get("comp_melee_flip"),
}
local use_melee_comps = mod:get("use_melee_override")
local using_melee = false

local prev_fade_instruction = nil
local upd_component_style = true

mod.on_setting_changed = function(id)
    if string.find(id, COMP_BASE_PREFIX) then
        local key = string.sub(id, string.len(COMP_BASE_PREFIX))
        base_components[key] = mod:get(id)
        if not (use_melee_comps and using_melee) then
            upd_component_style = true
        end
    elseif string.find(id, COMP_MELEE_PREFIX) then
        local key = string.sub(id, string.len(COMP_MELEE_PREFIX))
        melee_components[key] = mod:get(id)
        if use_melee_comps and using_melee then
            upd_component_style = true
        end
    elseif id == "use_melee_override" then
        use_melee_comps = mod:get(id)
    elseif id == "vis_behavior" then
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

mod:hook_safe(CLASS.HudElementBlocking, "init", function(...)
    upd_component_style = true
end)

mod:hook_safe(CLASS.PlayerUnitWeaponExtension, "on_slot_wielded", function(self, slot_name, ...)
    using_melee = slot_name == "slot_primary"
    if use_melee_comps then
        upd_component_style = true
    end
end)

mod:hook_safe(CLASS.HudElementBlocking, "update", function(self, ...)
    if upd_component_style then
        upd_component_style = false

        local comps = base_components
        if use_melee_comps and using_melee then
            comps = melee_components
        end

        local gauge_widget = self._widgets_by_name.gauge

        self._shield_widget.visible = comps.bar
        gauge_widget.style.warning.visible = comps.bracket
        gauge_widget.style.value_text.visible = comps.perc
        gauge_widget.style.name_text.visible = comps.lbl

        if comps.flip then
            gauge_widget.style.name_text.text_horizontal_alignment = "left"
            gauge_widget.style.name_text.horizontal_alignment = "left"
            gauge_widget.style.value_text.text_horizontal_alignment = "right"
            gauge_widget.style.value_text.horizontal_alignment = "right"
        else
            gauge_widget.style.value_text.text_horizontal_alignment = "left"
            gauge_widget.style.value_text.horizontal_alignment = "left"
            gauge_widget.style.name_text.text_horizontal_alignment = "right"
            gauge_widget.style.name_text.horizontal_alignment = "right"
        end
    end
end)

mod:hook(CLASS.HudElementBlocking, "_update_visibility", function(func, self, dt)
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

        if draw ~= prev_fade_instruction then
            if draw then
                appear_timeout = appear_delay
                vanish_timeout = 0.0
            else
                vanish_timeout = vanish_delay
                appear_timeout = 0.0
            end
        end
        prev_fade_instruction = draw

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
