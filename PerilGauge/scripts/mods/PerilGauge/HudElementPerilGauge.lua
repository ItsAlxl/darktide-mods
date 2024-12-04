local mod = get_mod("PerilGauge")

local ColorUtilities = require("scripts/utilities/ui/colors")
local Definitions = mod:io_dofile("PerilGauge/scripts/mods/PerilGauge/UIDefinitions")
local PlayerCharacterConstants = require("scripts/settings/player_character/player_character_constants")

local HudElementPerilGauge = class("HudElementPerilGauge", "HudElementBase")

local vis_behavior = mod:get("vis_behavior")
local perc_num_format = ""

local vanish_timeout = 0.0
local vanish_delay = mod:get("vanish_delay")
local vanish_speed = mod:get("vanish_speed")

local appear_timeout = 0.0
local appear_delay = mod:get("appear_delay")
local appear_speed = mod:get("appear_speed")

local override_peril_color = mod:get("override_peril_color")
local override_peril_alpha = mod:get("override_peril_alpha")
local override_peril_text = mod:get("override_peril_text")

local next_update_refresh_style = false
local prev_vis_instruction = nil
local current_alpha = 0.0
local alpha_mult = mod:get("gauge_alpha")

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
	return math.ilerp_no_clamp(thresh_idx > 1 and threshold_keys[thresh_idx - 1] or 0, threshold_keys[thresh_idx], value)
end

mod.on_setting_changed = function(id)
	if id == "override_peril_color" then
		override_peril_color = mod:get(id)
		mod.override_color = nil
	elseif id == "override_peril_alpha" then
		override_peril_alpha = mod:get(id)
		mod.override_alpha = nil
	elseif id == "override_peril_text" then
		override_peril_text = mod:get(id)
		mod.override_text = nil
	elseif id == "perc_num_decimals" or id == "perc_lead_zeroes" then
		local num_decimals = mod:get("perc_num_decimals")
		local num_lead_zeroes = mod:get("perc_lead_zeroes") + 1
		if num_decimals > 0 then
			num_lead_zeroes = num_lead_zeroes + num_decimals + 1
		end
		perc_num_format = "%0" .. num_lead_zeroes .. "." .. num_decimals .. "f%%"
	elseif id == "vis_behavior" then
		vis_behavior = mod:get(id)
	elseif id == "wep_counter_behavior" then
		mod.wep_counter_behavior = mod:get(id)
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
	elseif id == "gauge_alpha" then
		alpha_mult = mod:get(id)
	elseif id == "vanilla_alpha_mult" then
		mod.vanilla_alpha_mult = mod:get(id)
	elseif id == "special_alpha_mult" then
		mod.special_alpha_mult = mod:get(id)
	else
		next_update_refresh_style = true
	end
end
mod.on_setting_changed("perc_num_decimals")

HudElementPerilGauge.init = function(self, parent, draw_layer, start_scale)
	HudElementPerilGauge.super.init(self, parent, draw_layer, start_scale, Definitions)

	local weapon_slots = {}
	local slot_configuration = PlayerCharacterConstants.slot_configuration
	for slot_id, config in pairs(slot_configuration) do
		if config.slot_type == "weapon" then
			weapon_slots[#weapon_slots + 1] = slot_id
		end
	end
	self._wep_slots = weapon_slots
	self._num_wep_slots = #weapon_slots

	mod.override_alpha = nil
	mod.override_color = nil
	mod.override_text = nil
	next_update_refresh_style = true
end

local _apply_hgauge_label_spot = function(label_style, vert, horiz, bar_size, text_offset)
	label_style.text_vertical_alignment = "center"
	if horiz == -1 then
		label_style.text_horizontal_alignment = "left"
	elseif horiz == 1 then
		label_style.text_horizontal_alignment = "right"
	else
		label_style.text_horizontal_alignment = "center"
	end

	label_style.offset[1] = 0
	label_style.offset[2] = 0.5 * bar_size[2] + text_offset
	if vert == -1 then
		label_style.offset[2] = -label_style.offset[2]
	end
	label_style.size[1] = bar_size[1]
	label_style.size[2] = bar_size[2]
end

local _apply_vgauge_label_spot = function(label_style, vert, horiz, bar_size, text_offset)
	if vert == -1 then
		label_style.text_vertical_alignment = "top"
	elseif vert == 1 then
		label_style.text_vertical_alignment = "bottom"
	else
		label_style.text_vertical_alignment = "center"
	end

	label_style.offset[1] = 0.5 * (bar_size[1] + bar_size[2]) + text_offset
	label_style.offset[2] = 0
	if horiz == -1 then
		label_style.text_horizontal_alignment = "right"
		label_style.offset[1] = -label_style.offset[1]
	else
		label_style.text_horizontal_alignment = "left"
	end
	label_style.size[1] = bar_size[1]
	label_style.size[2] = bar_size[1]
end

HudElementPerilGauge.update = function(self, dt, t, ui_renderer, render_settings, input_service)
	local gauge_widget = self._widgets_by_name.gauge
	local gauge_widget_style = gauge_widget.style
	local bar_style = gauge_widget_style.bar

	-- Update component settings
	if next_update_refresh_style then
		next_update_refresh_style = false
		local label_style = gauge_widget_style.name_text
		local perc_style = gauge_widget_style.perc_text
		local bracket_style = gauge_widget_style.bracket

		-- Because this section only runs once after settings are
		-- changed, I think it's fine to use mod:get(...) a few times.
		-- Ideally, this would go in its own function which would only be
		-- called after settings change, but this is easier for me so :)
		bracket_style.visible = mod:get("comp_bracket")

		local lbl_text = mod:get("lbl_text")
		if lbl_text == "lbl_text_none" then
			label_style.visible = false
		else
			gauge_widget.content.name_text = mod:localize(lbl_text)
			label_style.visible = true
		end
		perc_style.visible = mod:get("show_perc")

		local bar_size = { mod:get("gauge_length"), mod:get("gauge_thick") }
		local orientation = mod:get("comp_orientation")
		local bar_dir = mod:get("bar_direction")
		local perc_vert = mod:get("perc_vert")
		local perc_horiz = mod:get("perc_horiz")
		local lbl_vert = mod:get("lbl_vert")
		local lbl_horiz = mod:get("lbl_horiz")
		local text_offset = 5 * Definitions.default_values.bar_bracket_spacing

		bracket_style.size = { bar_size[1] + 2.0 * Definitions.default_values.bar_bracket_spacing, bar_size[2] }
		bracket_style.pivot = { 0.5 * bracket_style.size[1], 0.5 * bracket_style.size[2] }
		bracket_style.angle = orientation * math.pi * 0.5

		if orientation == 0 or orientation == 2 then
			bar_size_full[1] = bar_size[1]
			bar_size_full[2] = bar_size[2]
			bar_size_empty[1] = 0
			bar_size_empty[2] = bar_size_full[2]

			_apply_hgauge_label_spot(perc_style, perc_vert, perc_horiz, bar_size, text_offset)
			_apply_hgauge_label_spot(label_style, lbl_vert, lbl_horiz, bar_size, text_offset)

			bar_style.offset[1] = 0.5 * (Definitions.default_values.area_side - bar_size[1])
			bar_style.offset[2] = 0
			bar_style.vertical_alignment = "center"
			if bar_dir == 3 then
				bar_style.horizontal_alignment = "center"
				bar_style.offset[1] = 0
			elseif bar_dir == 1 then
				bar_style.horizontal_alignment = "left"
			else
				bar_style.horizontal_alignment = "right"
				bar_style.offset[1] = -bar_style.offset[1]
			end
		else
			bar_size_full[1] = bar_size[2]
			bar_size_full[2] = bar_size[1]
			bar_size_empty[1] = bar_size_full[1]
			bar_size_empty[2] = 0

			_apply_vgauge_label_spot(perc_style, perc_vert, perc_horiz, bar_size, text_offset)
			_apply_vgauge_label_spot(label_style, lbl_vert, lbl_horiz, bar_size, text_offset)

			bar_style.offset[1] = 0
			bar_style.offset[2] = 0.5 * (Definitions.default_values.area_side - bar_size[1])
			bar_style.horizontal_alignment = "center"
			if bar_dir == 3 then
				bar_style.vertical_alignment = "center"
				bar_style.offset[2] = 0
			elseif bar_dir == 1 then
				bar_style.vertical_alignment = "bottom"
				bar_style.offset[2] = -bar_style.offset[2]
			else
				bar_style.vertical_alignment = "top"
			end
		end
	end

	HudElementPerilGauge.super.update(self, dt, t, ui_renderer, render_settings, input_service)

	-- if the wep counter has us covered, just hide
	if mod.wep_counter_vis and mod.wep_counter_behavior == 0 then
		current_alpha = 0.0
		mod.override_alpha = override_peril_alpha and current_alpha
		return
	end

	-- Determine peril fraction
	local player_extensions = self._parent:player_extensions()
	local player_unit_data = player_extensions and player_extensions.unit_data

	local warp_charge_level = player_unit_data and player_unit_data:read_component("warp_charge").current_percentage or 0
	local overheat_level = 0
	if player_unit_data then
		local weapon_extension = player_extensions.weapon
		local weapon_template = weapon_extension:weapon_template()
		local use_current_wep = weapon_template and weapon_template.uses_overheat

		if use_current_wep then
			local wielded_slot = player_unit_data:read_component("inventory").wielded_slot
			if wielded_slot and wielded_slot ~= "none" then
				local slot_configuration = PlayerCharacterConstants.slot_configuration[wielded_slot]
				if slot_configuration.slot_type == "weapon" then
					overheat_level = player_unit_data:read_component(wielded_slot).overheat_current_percentage
				end
			end
		else
			local wep_slots = self._wep_slots
			for i = 1, self._num_wep_slots do
				overheat_level = math.max(player_unit_data:read_component(wep_slots[i]).overheat_current_percentage, overheat_level)
			end
		end

	end
	if warp_charge_level ~= overheat_level then
		mod.is_peril_driven = warp_charge_level > overheat_level
	end
	local peril_fraction = mod.is_peril_driven and warp_charge_level or overheat_level

	-- Update visibility
	if vis_behavior == 0 then
		local vis_instruction = peril_fraction > 0
		if prev_vis_instruction ~= nil then
			if vis_instruction ~= prev_vis_instruction then
				appear_timeout = vis_instruction and appear_delay or 0.0
				vanish_timeout = vis_instruction and 0.0 or vanish_delay
			end

			vanish_timeout = vanish_timeout > 0.0 and (vanish_timeout - dt) or -1.0
			appear_timeout = appear_timeout > 0.0 and (appear_timeout - dt) or -1.0

			local appear = vis_instruction
			if vanish_timeout <= 0.0 and appear_timeout > 0.0 then
				appear = false
			elseif appear_timeout <= 0.0 and vanish_timeout > 0.0 then
				appear = true
			end

			local alpha_multiplier = current_alpha or 0.0
			alpha_multiplier = appear
				and (appear_speed > 0.0 and math.min(alpha_multiplier + dt * appear_speed, 1.0) or 1.0)
				or (vanish_speed > 0.0 and math.max(alpha_multiplier - dt * vanish_speed, 0.0) or 0.0)
			current_alpha = alpha_multiplier
		end
		prev_vis_instruction = vis_instruction
	else
		current_alpha = vis_behavior > 0 and 1.0 or 0.0
	end

	-- Set bar size & color
	local color = bar_style.color
	if num_thresholds > 0 then
		local thresh_idx = _get_next_threshold_idx(peril_fraction)
		if thresh_idx == nil then
			ColorUtilities.color_copy(_get_threshold_after_color(num_thresholds), color)
		elseif threshold_keys[thresh_idx] == peril_fraction then
			ColorUtilities.color_copy(_get_threshold_after_color(thresh_idx), color)
		else
			ColorUtilities.color_lerp(_get_threshold_after_color(thresh_idx - 1), _get_threshold_before_color(thresh_idx), _get_threshold_lerp(thresh_idx, peril_fraction), color, false)
		end
	end
	bar_style.size[1] = math.lerp(bar_size_empty[1], bar_size_full[1], peril_fraction)
	bar_style.size[2] = math.lerp(bar_size_empty[2], bar_size_full[2], peril_fraction)

	-- Set percentage text & overrides
	local perc_text = string.format(perc_num_format, peril_fraction * 100)
	gauge_widget.content.perc_text = perc_text

	mod.override_alpha = override_peril_alpha and current_alpha
	mod.override_color = override_peril_color and color
	mod.override_text = override_peril_text and perc_text
end

HudElementPerilGauge._draw_widgets = function(self, dt, t, input_service, ui_renderer, render_settings)
	if current_alpha ~= 0 then
		local previous_alpha_multiplier = render_settings.alpha_multiplier or 1
		render_settings.alpha_multiplier = previous_alpha_multiplier * current_alpha * alpha_mult

		HudElementPerilGauge.super._draw_widgets(self, dt, t, input_service, ui_renderer, render_settings)

		render_settings.alpha_multiplier = previous_alpha_multiplier
	end
end

return HudElementPerilGauge
