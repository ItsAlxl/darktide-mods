local mod = get_mod("TruePeril")
local EPSILON = 0.00392156862745098

-- modified from "scripts/ui/hud/elements/overcharge/hud_element_overcharge.lua"
mod:hook("HudElementOvercharge", "_update_overcharge", function(func, self, dt)
    local warp_charge_level = 0
    local parent = self._parent
    local player_extensions = parent:player_extensions()

    if player_extensions then
        local player_unit_data = player_extensions.unit_data

        if player_unit_data then
            local warp_charge_component = player_unit_data:read_component("warp_charge")
            warp_charge_level = warp_charge_component.current_percentage
        end
    end

    local widget = self._widgets_by_name.overcharge

    if warp_charge_level == 0 then
        if widget.visible then
            widget.visible = false
            widget.dirty = true
        end

        self._warp_charge_level = warp_charge_level

        return
    end

    --[[ Simply don't lerp. That's the whole mod.
    if warp_charge_level < self._warp_charge_level - EPSILON then
        warp_charge_level = math.lerp(self._warp_charge_level, warp_charge_level, dt * 2)
    end
    --]]

    local previous_anim_progress = widget.content.anim_progress
    local animate_in = warp_charge_level > 0.75
    local anim_progress = self:_get_animation_progress(dt, previous_anim_progress, animate_in)

    if previous_anim_progress ~= anim_progress then
        widget.content.anim_progress = anim_progress
    end

    self:_animate_widget_warnings(widget, warp_charge_level, dt)

    local old_warning_text = widget.content.warning_text
    local new_warning_text = "" .. string.format("%.0f%%", warp_charge_level * 100)
    widget.content.warning_text = new_warning_text

    if old_warning_text ~= new_warning_text then
        widget.dirty = true
    end

    local visible = EPSILON < warp_charge_level
    self._warp_charge_alpha_multiplier = self:_update_visibility(dt, visible, self._warp_charge_alpha_multiplier)
    local alpha_multiplier = math.clamp(self._warp_charge_alpha_multiplier * 0.5 + warp_charge_level * 0.5, 0, 1)

    if EPSILON < math.abs((widget.alpha_multiplier or 0) - alpha_multiplier) then
        widget.alpha_multiplier = alpha_multiplier
        widget.dirty = true
        widget.visible = EPSILON < alpha_multiplier
    end

    self._warp_charge_level = warp_charge_level
end)
