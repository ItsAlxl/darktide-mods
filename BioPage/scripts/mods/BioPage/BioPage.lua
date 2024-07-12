local mod = get_mod("BioPage")

local HomePlanets = require("scripts/settings/character/home_planets")
local Childhood = require("scripts/settings/character/childhood")
local GrowingUp = require("scripts/settings/character/growing_up")
local FormativeEvent = require("scripts/settings/character/formative_event")
local Crimes = require("scripts/settings/character/crimes")
local Personalities = require("scripts/settings/character/personalities")

local ButtonPassTemplates = require("scripts/ui/pass_templates/button_pass_templates")
local UIFonts = require("scripts/managers/ui/ui_fonts")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local UIRenderer = require("scripts/managers/ui/ui_renderer")

local text_style = table.clone(UIFontSettings.body)
text_style.offset = {
	0,
	0,
	100
}

local bg_padding = 10
local bio_entry_size = { 750, 40 }
local vert_spacing = 20 + bio_entry_size[2]
local missing_text = Localize("loc_popup_header_service_unavailable_error")

local bio_btn_widgets = {}
local bio_text_widget = nil
local bio_current_idx = -1

-- Handle accordion
local show_bio_text_at_idx = function(idx)
	bio_current_idx = idx == bio_current_idx and -1 or idx

	local text_height = 0
	if bio_current_idx < 0 then
		bio_text_widget.visible = false
	else
		bio_text_widget.visible = true
		bio_text_widget.offset[2] = vert_spacing * (idx + 1) - bg_padding

		local bio_data = bio_btn_widgets[idx].content.bio_data
		bio_text_widget.content.text = bio_data and (Localize(bio_data.description) .. (bio_data.story_snippet and ("\n\n" .. Localize(bio_data.story_snippet)) or "")) or missing_text

		text_height = bg_padding + UIRenderer.text_height(Managers.ui:ui_constant_elements():ui_renderer(), bio_text_widget.content.text, text_style.font_type, text_style.font_size, { bio_entry_size[1], 2000 }, UIFonts.get_font_options_by_style(text_style))
		bio_text_widget.content.size[2] = text_height - bg_padding
	end

	for btn_idx, widget in ipairs(bio_btn_widgets) do
		widget.offset[2] = vert_spacing * btn_idx + (btn_idx > idx and text_height or 0)
	end
end

-- Add scenegraph definitions
mod:hook_require("scripts/ui/views/inventory_view/inventory_view_definitions", function(view_defs)
	view_defs.scenegraph_definition.bio_entry = {
		parent = "canvas",
		horizontal_alignment = "left",
		vertical_alignment = "top",
		size = bio_entry_size,
		position = {
			250,
			180,
			1
		}
	}
end)

-- Add blueprints
mod:hook_require("scripts/ui/views/inventory_view/inventory_view_content_blueprints", function(blueprints)
	blueprints.bio_button = {
		size = bio_entry_size,
		pass_template = ButtonPassTemplates.terminal_button_small,
		init = function(parent, widget, element, callback_name)
			local content = widget.content
			local bio_data = element.bio_data
			content.text = element.bio_title .. (bio_data and (" - " .. Localize(bio_data.display_name)) or "")
			content.bio_data = bio_data
			content.bio_idx = element.bio_idx
			widget.offset[2] = vert_spacing * element.bio_idx

			bio_btn_widgets[element.bio_idx] = widget
			content.hotspot.pressed_callback = function()
				show_bio_text_at_idx(element.bio_idx)
			end
		end,
		destroy = function(parent, widget, element, ui_renderer)
			bio_btn_widgets[widget.content.bio_idx] = nil
		end,
	}

	blueprints.bio_text = {
		size = bio_entry_size,
		pass_template = {
			{
				style_id = "bg",
				pass_type = "rect",
				style = {
					offset = {
						-bg_padding,
						-bg_padding,
						-2
					},
					size_addition = {
						2 * bg_padding,
						2 * bg_padding,
					},
					color = {
						128,
						0,
						0,
						0
					}
				}
			},
			{
				pass_type = "text",
				value = missing_text,
				value_id = "text",
				style = text_style,
			},
		},
		init = function(parent, widget, element, callback_name)
			widget.visible = false
			bio_text_widget = widget
		end,
		destroy = function(parent, widget, element, ui_renderer)
			bio_text_widget = nil
			bio_current_idx = -1
		end,
	}
end)

-- Add Bio tab to inventory view and populate it with info
mod:hook_safe(CLASS.InventoryBackgroundView, "_setup_top_panel", function(self, ...)
	local player = self._preview_player
	local profile = player:profile()
	local backstory = profile.lore and profile.lore.backstory

	local bio_tab = {
		display_name = mod:localize("bio_tab_name"),
		view_name = "inventory_view",
		update = function(content, style, dt)
			content.hotspot.disabled = not self:is_inventory_synced()
		end,
		view_context = {
			tabs = {
				{
					allow_item_hover_information = true,
					draw_wallet = false,
					is_grid_layout = false,
					ui_animation = "cosmetics_on_enter",
					camera_settings = {
						{
							"event_inventory_set_camera_position_axis_offset",
							"x",
							0,
							0.5,
							math.easeCubic,
						},
						{
							"event_inventory_set_camera_position_axis_offset",
							"y",
							0,
							0.5,
							math.easeCubic,
						},
						{
							"event_inventory_set_camera_position_axis_offset",
							"z",
							0,
							0.5,
							math.easeCubic,
						},
						{
							"event_inventory_set_camera_rotation_axis_offset",
							"x",
							0,
							0.5,
							math.easeCubic,
						},
						{
							"event_inventory_set_camera_rotation_axis_offset",
							"y",
							0,
							0.5,
							math.easeCubic,
						},
						{
							"event_inventory_set_camera_rotation_axis_offset",
							"z",
							0,
							0.5,
							math.easeCubic,
						},
					},
					layout = {
						{
							scenegraph_id = "bio_entry",
							widget_type = "bio_button",
							bio_title = Localize("loc_character_birthplace_planet_title_name"),
							bio_data = backstory.planet and HomePlanets[backstory.planet],
							bio_idx = 0,
						},
						{
							scenegraph_id = "bio_entry",
							widget_type = "bio_button",
							bio_title = Localize("loc_character_childhood_title_name"),
							bio_data = backstory.childhood and Childhood[backstory.childhood],
							bio_idx = 1,
						},
						{
							scenegraph_id = "bio_entry",
							widget_type = "bio_button",
							bio_title = Localize("loc_character_growing_up_title_name"),
							bio_data = backstory.growing_up and GrowingUp[backstory.growing_up],
							bio_idx = 2,
						},
						{
							scenegraph_id = "bio_entry",
							widget_type = "bio_button",
							bio_title = Localize("loc_character_event_title_name"),
							bio_data = backstory.formative_event and FormativeEvent[backstory.formative_event],
							bio_idx = 3,
						},
						{
							scenegraph_id = "bio_entry",
							widget_type = "bio_button",
							bio_title = Localize("loc_character_create_title_crime"),
							bio_data = backstory.crime and Crimes[backstory.crime],
							bio_idx = 4,
						},
						{
							scenegraph_id = "bio_entry",
							widget_type = "bio_button",
							bio_title = Localize("loc_character_create_title_personality"),
							bio_data = backstory.personality and Personalities[backstory.personality],
							bio_idx = 5,
						},
						{
							scenegraph_id = "bio_entry",
							widget_type = "bio_text",
						},
					},
				},
			},
		},
	}

	local bio_tab_idx = #self._views_settings + 1
	self._views_settings[bio_tab_idx] = bio_tab

	local function entry_callback_function()
		self:_on_panel_option_pressed(bio_tab_idx)
	end
	local optional_update_function = bio_tab.update
	local cb = callback(entry_callback_function)

	self._top_panel:add_entry(bio_tab.display_name, cb, optional_update_function)
end)
