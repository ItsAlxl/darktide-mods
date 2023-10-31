local mod = get_mod("PerilGauge")

local ColorUtilities = require("scripts/utilities/ui/colors")
local Definitions = mod:io_dofile("PerilGauge/scripts/mods/PerilGauge/UIDefinitions")
local PlayerCharacterConstants = require("scripts/settings/player_character/player_character_constants")

local HudElementPerilGauge = class("HudElementPerilGauge", "HudElementBase")

local vis_behavior = mod:get("vis_behavior")

local vanish_timeout = 0.0
local vanish_delay = mod:get("vanish_delay")
local vanish_speed = mod:get("vanish_speed")

local appear_timeout = 0.0
local appear_delay = mod:get("appear_delay")
local appear_speed = mod:get("appear_speed")

local override_peril_color = mod:get("override_peril_color")

local next_update_refresh_style = false
local prev_vis_instruction = nil
local current_alpha = 0.0

local bar_size_empty = { 0, 0 }
local bar_size_full = { 0, 0 }

local thresholds = mod:io_dofile("PerilGauge/scripts/mods/PerilGauge/Thresholds")
local num_thresholds = 0
local threshold_keys = {}
for k, _ in pairs(thresholds) do
    num_thresholds = num_thresholds + 1
    threshold_keys[num_thresholds] = k
end
table.sort(threshold_keys)

local _get_threshold_before_color = function(idx)
    local key = threshold_keys[idx]
    local thresh = key and thresholds[key]
    return thresh and (thresh.before or thresh.after) or Definitions.default_values.bar_color
end

local _get_threshold_after_color = function(idx)
    local key = threshold_keys[idx]
    local thresh = key and thresholds[key]
    return thresh and (thresh.after or thresh.before) or Definitions.default_values.bar_color
end

local _get_next_threshold_idx = function(value)
    for i = 1, num_thresholds do
        if threshold_keys[i] >= value then
            return i
        end
    end
    return nil
end

local _get_threshold_lerp = function(thresh_idx, value)
    local prev_value = 0
    if thresh_idx > 1 then
        prev_value = threshold_keys[thresh_idx - 1]
    end
    local curr_value = threshold_keys[thresh_idx]

    return math.ilerp_no_clamp(prev_value, curr_value, value)
end

mod.on_setting_changed = function(id)
    if id == "override_peril_color" then
        override_peril_color = mod:get(id)
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
    else
        next_update_refresh_style = true
    end
end

HudElementPerilGauge.init = function(self, parent, draw_layer, start_scale)
    HudElementPerilGauge.super.init(self, parent, draw_layer, start_scale, Definitions)

    local weapon_slots = {}
    local slot_configuration = PlayerCharacterConstants.slot_configuration
    for slot_id, config in pairs(slot_configuration) do
        if config.slot_type == "weapon" then
            weapon_slots[#weapon_slots + 1] = slot_id
        end
    end
    self._weapon_slots = weapon_slots

    next_update_refresh_style = true
end

HudElementPerilGauge.update = function(self, dt, t, ui_renderer, render_settings, input_service)
    local gauge_widget_style = self._widgets_by_name.gauge.style
    local segment_style = gauge_widget_style.segment

    -- Update component settings
    if next_update_refresh_style then
        next_update_refresh_style = false
        local label_style = gauge_widget_style.name_text

        -- Because this section only runs once after settings are
        -- changed, I think it's fine to use mod:get(...) a few times.
        -- Ideally, this would go in its own function which would only be
        -- called after settings change, but this is easier for me so :)
        gauge_widget_style.bracket.visible = mod:get("comp_bracket")

        local lbl_text = mod:get("lbl_text")
        if lbl_text == "lbl_text_none" then
            label_style.visible = false
        else
            self._widgets_by_name.gauge.content.name_text = mod:localize(lbl_text)
            label_style.visible = true
        end

        local orientation = mod:get("comp_orientation")
        local bar_direction = mod:get("bar_direction")
        local lbl_vert = mod:get("lbl_vert")
        local lbl_horiz = mod:get("lbl_horiz")
        gauge_widget_style.bracket.angle = orientation * math.pi * 0.5

        if orientation == 0 or orientation == 2 then
            label_style.text_vertical_alignment = "center"
            if lbl_horiz == -1 then
                label_style.text_horizontal_alignment = "left"
            elseif lbl_horiz == 1 then
                label_style.text_horizontal_alignment = "right"
            else
                label_style.text_horizontal_alignment = "center"
            end
            label_style.offset[1] = 0
            label_style.offset[2] = 2 * Definitions.default_values.bar_size[2]
            if lbl_vert == -1 then
                label_style.offset[2] = -label_style.offset[2]
            end

            segment_style.vertical_alignment = "center"
            if bar_direction == 0 then
                segment_style.horizontal_alignment = "center"
            elseif (bar_direction == -1 and orientation == 0) or (bar_direction == 1 and orientation == 2) then
                segment_style.horizontal_alignment = "right"
            else
                segment_style.horizontal_alignment = "left"
            end

            bar_size_full[1] = Definitions.default_values.bar_size[1]
            bar_size_full[2] = Definitions.default_values.bar_size[2]
            bar_size_empty[1] = 0
            bar_size_empty[2] = bar_size_full[2]
        else
            if lbl_vert == -1 then
                label_style.text_vertical_alignment = "top"
            elseif lbl_vert == 1 then
                label_style.text_vertical_alignment = "bottom"
            else
                label_style.text_vertical_alignment = "center"
            end
            label_style.offset[1] = Definitions.default_values.bar_size[1] * 0.5 + 2 * Definitions.default_values.bar_size[2]
            label_style.offset[2] = 0
            if lbl_horiz == -1 then
                label_style.text_horizontal_alignment = "right"
                label_style.offset[1] = -label_style.offset[1]
            else
                label_style.text_horizontal_alignment = "left"
            end

            segment_style.horizontal_alignment = "center"
            if bar_direction == 0 then
                segment_style.vertical_alignment = "center"
            elseif (bar_direction == -1 and orientation == 1) or (bar_direction == 1 and orientation == 3) then
                segment_style.vertical_alignment = "top"
            else
                segment_style.vertical_alignment = "bottom"
            end

            bar_size_full[1] = Definitions.default_values.bar_size[2]
            bar_size_full[2] = Definitions.default_values.bar_size[1]
            bar_size_empty[1] = bar_size_full[1]
            bar_size_empty[2] = 0
        end
    end

    HudElementPerilGauge.super.update(self, dt, t, ui_renderer, render_settings, input_service)

    -- Determine peril fraction
    local player_extensions = self._parent:player_extensions()
    local player_unit_data = player_extensions and player_extensions.unit_data

    local warp_charge_level = player_unit_data and player_unit_data:read_component("warp_charge").current_percentage or 0
    local overheat_level = 0
    if player_unit_data then
        local weapon_extension = player_extensions.weapon
        local weapon_template = weapon_extension:weapon_template()

        if weapon_template and weapon_template.uses_overheat then
            local wielded_slot = player_unit_data:read_component("inventory").wielded_slot
            if wielded_slot and wielded_slot ~= "none" then
                local slot_configuration = PlayerCharacterConstants.slot_configuration[wielded_slot]
                if slot_configuration.slot_type == "weapon" then
                    overheat_level = player_unit_data:read_component(wielded_slot).overheat_current_percentage
                end
            end
        else
            local weapon_slots = self._weapon_slots
            for i = 1, #weapon_slots do
                overheat_level = math.max(player_unit_data:read_component(weapon_slots[i]).overheat_current_percentage, overheat_level)
            end
        end
    end
    local peril_fraction = math.max(warp_charge_level, overheat_level)

    -- Update visibility
    if vis_behavior > 0 then
        current_alpha = 1.0
    elseif vis_behavior < 0 then
        current_alpha = 0.0
    else
        local vis_instruction = peril_fraction > 0
        if vis_instruction ~= prev_vis_instruction then
            if vis_instruction then
                appear_timeout = appear_delay
                vanish_timeout = 0.0
            else
                vanish_timeout = vanish_delay
                appear_timeout = 0.0
            end
        end
        prev_vis_instruction = vis_instruction

        if vanish_timeout > 0.0 then
            vanish_timeout = vanish_timeout - dt
        end
        if appear_timeout > 0.0 then
            appear_timeout = appear_timeout - dt
        end

        local appear = vis_instruction
        if vanish_timeout <= 0.0 and appear_timeout > 0.0 then
            appear = false
        elseif appear_timeout <= 0.0 and vanish_timeout > 0.0 then
            appear = true
        end

        local alpha_multiplier = current_alpha or 0.0
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
        current_alpha = alpha_multiplier
    end

    -- Set bar size & color
    local color = Definitions.default_values.bar_color
    if num_thresholds > 0 then
        local thresh_idx = _get_next_threshold_idx(peril_fraction)
        if thresh_idx == nil then
            color = _get_threshold_after_color(num_thresholds)
        elseif threshold_keys[thresh_idx] == peril_fraction then
            color = _get_threshold_after_color(thresh_idx)
        else
            color = table.clone(color)
            ColorUtilities.color_lerp(_get_threshold_after_color(thresh_idx - 1), _get_threshold_before_color(thresh_idx), _get_threshold_lerp(thresh_idx, peril_fraction), color, false)
        end
    end

    mod.override_peril_color = override_peril_color and color
    segment_style.color = color
    segment_style.size[1] = math.lerp(bar_size_empty[1], bar_size_full[1], peril_fraction)
    segment_style.size[2] = math.lerp(bar_size_empty[2], bar_size_full[2], peril_fraction)
end

HudElementPerilGauge._draw_widgets = function(self, dt, t, input_service, ui_renderer, render_settings)
    if current_alpha ~= 0 then
        local previous_alpha_multiplier = render_settings.alpha_multiplier or 1
        render_settings.alpha_multiplier = previous_alpha_multiplier * current_alpha

        HudElementPerilGauge.super._draw_widgets(self, dt, t, input_service, ui_renderer, render_settings)

        render_settings.alpha_multiplier = previous_alpha_multiplier
    end
end

return HudElementPerilGauge
