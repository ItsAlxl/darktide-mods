local mod = get_mod("ServoSkullNametag")

local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local UISettings = require("scripts/settings/ui/ui_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")

local template = {}
local size = {
	400,
	20,
}
local arrow_size = {
	60,
	60,
}
local icon_size = {
	128,
	128,
}

template.size = size
template.name = "nameplate_companion"
template.unit_node = "companion_name"
template.position_offset = {
	0,
	0,
	0,
}
template.check_line_of_sight = false
template.max_distance = 100
template.screen_clamp = true
template.screen_margins = {
	down = 0.09259259259259259,
	left = 0.052083333333333336,
	right = 0.052083333333333336,
	up = 0.09259259259259259,
}
template.scale_settings = {
	distance_max = 100,
	distance_min = 10,
	scale_from = 0.8,
	scale_to = 1,
}

template.create_widget_defintion = function(_, scenegraph_id)
	local header_font_setting_name = "hud_body"
	local header_font_settings = UIFontSettings[header_font_setting_name]
	local header_font_color = header_font_settings.text_color

	return UIWidget.create_definition({
		{
			pass_type = "text",
			style_id = "header_text",
			value = "<header_text>",
			value_id = "header_text",
			style = {
				horizontal_alignment = "center",
				text_horizontal_alignment = "center",
				text_vertical_alignment = "center",
				vertical_alignment = "center",
				offset = {
					0,
					0,
					2,
				},
				text_color = header_font_color,
				font_type = header_font_settings.font_type,
				font_size = header_font_settings.font_size,
				default_font_size = header_font_settings.font_size,
				default_text_color = header_font_color,
				size = size,
			},
			visibility_function = function(content, _)
				return content.wants_visible and not content.is_clamped
			end,
		},
		{
			pass_type = "text",
			style_id = "icon_text",
			value = "<icon_text>",
			value_id = "icon_text",
			style = {
				drop_shadow = false,
				font_size = 32,
				horizontal_alignment = "center",
				text_horizontal_alignment = "center",
				text_vertical_alignment = "center",
				vertical_alignment = "center",
				offset = {
					0,
					-3,
					2,
				},
				font_type = header_font_settings.font_type,
				default_font_size = header_font_settings.font_size,
				text_color = header_font_color,
				default_text_color = header_font_color,
				size = icon_size,
			},
			visibility_function = function(content, _)
				return content.wants_visible and content.is_clamped
			end,
		},
		{
			pass_type = "rotated_texture",
			style_id = "arrow",
			value = "content/ui/materials/hud/interactions/frames/direction",
			value_id = "arrow",
			style = {
				horizontal_alignment = "center",
				vertical_alignment = "center",
				size = arrow_size,
				offset = {
					0,
					0,
					5,
				},
				color = Color.ui_hud_green_super_light(255, true),
			},
			visibility_function = function(content, _)
				return content.wants_visible and content.is_clamped
			end,
			change_function = function(content, style)
				style.angle = content.angle
			end,
		},
	}, scenegraph_id)
end

local _get_glyph = function(data)
	local player_slot = data.player:slot()
	local color = UISettings.player_slot_colors[player_slot] or Color.ui_hud_green_light(255, true)
	return "{#color(" .. color[2] .. "," .. color[3] .. "," .. color[4] .. ")}"
		.. mod:get("icon_" .. data.skull_type)
		.. "{#reset()}"
end

mod.refresh_marker_text = function(marker)
	local data = marker.data
	local player = data.player
	local is_player_blocked = player.is_player_blocked and player:is_player_blocked() or false
	local name = is_player_blocked and Localize("loc_blocking_player")
		or mod.get_skull_name(data.player, data.skull_type)
	if name ~= "" then
		name = " " .. name
	end

	local content = marker.widget.content
	content.icon_text = _get_glyph(marker.data)
	content.header_text = _get_glyph(data) .. name
end

mod.refresh_marker_visibility = function(marker)
	local data = marker.data
	local option = mod:get(data.in_hub and "vis_hub" or "vis_mission")
	marker.widget.content.wants_visible = option == "all"
		or option == "mine" and data.player:peer_id() == Network.peer_id()
end

template.on_enter = function(widget, marker)
	local data = marker.data
	local content = widget.content

	if data.in_hub then
		template.max_distance = 15
		template.fade_settings = {
			default_fade = 1,
			fade_from = 0,
			fade_to = 1,
			distance_max = template.max_distance,
			distance_min = template.max_distance * 0.5,
			easing_function = math.ease_exp,
		}
	else
		template.max_distance = 100
		template.fade_settings = nil
	end

	content.icon_text = _get_glyph(data)
	mod.refresh_marker_text(marker)
	mod.refresh_marker_visibility(marker)
	mod.track_nameplate(marker)
end

template.on_exit = function(_, marker)
	mod.untrack_nameplate(marker)
end

template.update_function = function(_, _, widget, marker, _, dt, _)
	local content = widget.content
	local style = widget.style
	local line_of_sight_progress = content.line_of_sight_progress or 0

	if marker.raycast_initialized then
		local line_of_sight_speed = 3
		line_of_sight_progress = marker.raycast_result and math.max(line_of_sight_progress - dt * line_of_sight_speed, 0)
			or math.min(line_of_sight_progress + dt * line_of_sight_speed, 1)
	end

	local edge_clamp_speed = 2.5
	local edge_clamp_progress = content.edge_clamp_progress or 0
	edge_clamp_progress = content.is_clamped and math.max(edge_clamp_progress - dt * edge_clamp_speed, 0)
		or math.min(edge_clamp_progress + dt * edge_clamp_speed, 1)

	if marker.draw then
		local header_style = style.header_text

		header_style.font_size = header_style.default_font_size * marker.scale
		content.line_of_sight_progress = line_of_sight_progress
		widget.alpha_multiplier = 1
		content.edge_clamp_progress = edge_clamp_progress

		local clamped_alpha = content.distance > (marker.data.in_hub and 1 or 15) and (255 * (1 - edge_clamp_progress)) or
		0
		style.icon_text.text_color[1] = clamped_alpha
		style.arrow.color[1] = clamped_alpha
	end
end

return template
