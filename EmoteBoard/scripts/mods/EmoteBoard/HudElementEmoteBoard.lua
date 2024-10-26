local mod = get_mod("EmoteBoard")

local ItemBlueprints = require("scripts/ui/view_content_blueprints/item_blueprints")
local ItemSlotSettings = require("scripts/settings/item/item_slot_settings")
local ItemUtils = require("scripts/utilities/items")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local ViewElementGrid = require("scripts/ui/view_elements/view_element_grid/view_element_grid")

local tooltip_text_style = table.clone(UIFontSettings.body)
tooltip_text_style.text_horizontal_alignment = "center"
tooltip_text_style.text_vertical_alignment = "center"
tooltip_text_style.horizontal_alignment = "center"
tooltip_text_style.vertical_alignment = "center"
tooltip_text_style.color = Color.white(255, true)
tooltip_text_style.offset = {
	0,
	0,
	2
}

local edge_padding = 35
local grid_width = 440
local grid_height = 500
local grid_size = {
	grid_width - edge_padding,
	grid_height,
}
local mask_size = {
	grid_width + 40,
	grid_height,
}
local ui_definitions = {
	scenegraph_definition = {
		screen = UIWorkspaceSettings.screen,
		emote_board_panel = {
			parent = "screen",
			vertical_alignment = "center",
			horizontal_alignment = "center",
			size = grid_size,
			position = { grid_width, -25, 100 }
		},
		emote_name_panel = {
			parent = "emote_board_panel",
			vertical_alignment = "bottom",
			horizontal_alignment = "center",
			size = { 250, 50 },
			position = { 0, 60, 0 }
		}
	},
	widget_definitions = {
		emote_name = UIWidget.create_definition({
			{
				pass_type = "rect",
				style_id = "background",
				style = {
					vertical_alignment = "center",
					horizontal_alignment = "center",
					offset = {
						0,
						0,
						1
					},
					color = Color.black(255, true),
					size_addition = {
						5,
						10
					}
				}
			},
			{
				pass_type = "rect",
				style = {
					vertical_alignment = "center",
					horizontal_alignment = "center",
					offset = {
						0,
						0,
						2
					},
					color = Color.black(192, true),
					size_addition = {
						0,
						5
					}
				}
			},
			{
				value_id = "text",
				pass_type = "text",
				value = "Emote Name",
				style = tooltip_text_style
			}
		}, "emote_name_panel")
	}
}

local HudElementEmoteBoard = class("HudElementEmoteBoard", "HudElementBase")
local NUM_EMOTE_SLOTS = 5
local EMOTE_SLOT_PREFIX = "slot_animation_emote_"
local EMOTE_EVENT_PREFIX = "emote_"

HudElementEmoteBoard.init = function(self, parent, draw_layer, start_scale)
	HudElementEmoteBoard.super.init(self, parent, draw_layer, start_scale, ui_definitions)
	self._player = Managers.player:local_player(1)
	self._slot_idx = 0
	self:_create_grid()
	self:refresh_inventory()
	self:set_visibility(false)
end

HudElementEmoteBoard.refresh_inventory = function(self)
	local plr_profile = self._player:profile()
	local plr_archetype = plr_profile.archetype
	local plr_crime = plr_profile.lore.backstory.crime
	local plr_archetype_name = plr_archetype.name
	local plr_breed_name = plr_archetype.breed

	local slot_name = EMOTE_SLOT_PREFIX .. 1
	self._grid_layout = {}
	Managers.data_service.gear:fetch_inventory(self._player:character_id(), { slot_name }):next(function(items)
		if self._destroyed then
			return
		end

		local layout = {}
		for _, item in pairs(items) do
			if (not item.archetypes or table.contains(item.archetypes, plr_archetype_name)) and
				(not item.breeds or table.contains(item.breeds, plr_breed_name)) and
				((item.crimes == nil or table.is_empty(item.crimes)) or (not item.crimes or table.contains(item.crimes, plr_crime))) and
				(item.slots and table.contains(item.slots, slot_name)) then
				layout[#layout + 1] = {
					item = item,
					slot = ItemSlotSettings[slot_name],
					widget_type = "ui_item",
					profile = plr_profile,
				}
			end
		end
		table.sort(layout, function(a, b) return a.item.__master_item.rarity < b.item.__master_item.rarity end)

		self._grid_layout = layout
		self:_apply_layout()
	end):catch(function()
		self:_apply_layout()
	end)
end

HudElementEmoteBoard._create_grid = function(self)
	self._item_grid = ViewElementGrid:new(self, 200, 1.0, {
		scrollbar_width = 10,
		use_is_focused_for_navigation = false,
		use_select_on_focused = true,
		use_terminal_background = true,
		widget_icon_load_margin = 400,
		grid_spacing = { 10, 10 },
		grid_size = grid_size,
		mask_size = mask_size,
		title_height = 70,
		edge_padding = edge_padding,
	})

	local pos = self:scenegraph_world_position("emote_board_panel")
	self._item_grid:set_pivot_offset(pos[1], pos[2])
end

HudElementEmoteBoard._apply_layout = function(self)
	local layout = self._grid_layout
	if #layout > 0 and layout[1].widget_type ~= "spacing_vertical" then
		local spacing_entry = {
			widget_type = "spacing_vertical",
		}
		table.insert(layout, 1, spacing_entry)
		table.insert(layout, #layout + 1, spacing_entry)
	end

	self._item_grid:present_grid_layout(layout, ItemBlueprints(grid_size), function(w, e) self:_cb_left_click(w, e) end, function(w, e) self:_cb_right_click(w, e) end, "loc_store_category_display_name_emotes", "down")
end

HudElementEmoteBoard._find_equipped_emote = function(self, item)
	local plr_profile = self._player:profile()
	local loadout = plr_profile and plr_profile.loadout
	if loadout then
		for i = 1, NUM_EMOTE_SLOTS do
			local equipped = loadout and loadout[EMOTE_SLOT_PREFIX .. i]
			if equipped and equipped.gear_id == item.gear_id then
				return i
			end
		end
	end
	return nil
end

HudElementEmoteBoard._cb_left_click = function(self, widget, element)
	local item = element.item
	local found_idx = self:_find_equipped_emote(item)
	if found_idx then
		self:perform_emote(found_idx)
	elseif not self._awaiting_gear or self._awaiting_gear ~= item.gear_id then
		self._slot_idx = ((self._slot_idx + 1) % NUM_EMOTE_SLOTS) + 1
		self._target_slot = EMOTE_SLOT_PREFIX .. self._slot_idx
		ItemUtils.equip_item_in_slot(self._target_slot, item)
		self._awaiting_gear = item.gear_id
	end
end

HudElementEmoteBoard._cb_right_click = function(self, widget, element)
	self._slot_idx = ((self._slot_idx + 1) % NUM_EMOTE_SLOTS) + 1
	ItemUtils.equip_item_in_slot(EMOTE_SLOT_PREFIX .. self._slot_idx, element.item)
end

HudElementEmoteBoard.set_visibility = function(self, visible)
	local was_visible = self._item_grid:visible()
	if visible == nil then
		visible = not was_visible
	end
	if visible == was_visible then
		return
	end

	local input_manager = Managers.input
	if visible and not self._cursor_pushed then
		input_manager:push_cursor(self.__class_name)
		input_manager:set_cursor_position(self.__class_name, Vector3(0.5, 0.5, 0))
		mod.take_camera_control = true
		self._cursor_pushed = true
	end
	if not visible and self._cursor_pushed then
		self._cursor_pushed = false
		input_manager:pop_cursor(self.__class_name)
		mod.take_camera_control = false
	end

	self._item_grid:set_visibility(visible)
end

HudElementEmoteBoard.draw = function(self, dt, t, ui_renderer, render_settings, input_service)
	HudElementEmoteBoard.super.draw(self, dt, t, ui_renderer, render_settings, input_service)
	self._item_grid:draw(dt, t, ui_renderer, render_settings, input_service)
end

HudElementEmoteBoard.update = function(self, dt, t, ui_renderer, render_settings, input_service)
	HudElementEmoteBoard.super.update(self, dt, t, ui_renderer, render_settings, input_service)

	local plr_profile = self._player:profile()
	local loadout = plr_profile and plr_profile.loadout
	local grid = self._item_grid
	if grid._visible then
		grid:update(dt, t, input_service)

		local equipped_emotes = {}
		for i = 1, NUM_EMOTE_SLOTS do
			local equipped = loadout and loadout[EMOTE_SLOT_PREFIX .. i]
			equipped_emotes[i] = equipped and equipped.gear_id or ""
		end
		for _, widget in ipairs(grid._grid_widgets) do
			local content = widget.content
			content.equipped = table.contains(equipped_emotes, content.item.gear_id)
		end
	end

	if self._awaiting_gear then
		local equipped = loadout and loadout[self._target_slot]
		if equipped and equipped.gear_id == self._awaiting_gear then
			self:perform_emote()
		end
	end

	local hovered_widget = grid:hovered_widget()
	local tooltip = self._widgets_by_name.emote_name
	if grid._visible and hovered_widget then
		tooltip.content.text = hovered_widget.content.display_name

		local bg_color = tooltip.style.background.color
		local target_color = hovered_widget.style.background_gradient.color
		bg_color[2] = target_color[2]
		bg_color[3] = target_color[3]
		bg_color[4] = target_color[4]

		tooltip.visible = true
	else
		tooltip.visible = false
	end
end

HudElementEmoteBoard.perform_emote = function(self, slot_idx)
	self._awaiting_gear = nil
	Managers.event:trigger("player_activate_emote", EMOTE_EVENT_PREFIX .. (slot_idx or self._slot_idx))
end

HudElementEmoteBoard.destroy = function(self, ui_renderer)
	self._item_grid:destroy(ui_renderer)
	HudElementEmoteBoard.super.destroy(self, ui_renderer)
end

HudElementEmoteBoard.ui_renderer = function(self)
	return Managers.ui:ui_constant_elements():ui_renderer()
end

return HudElementEmoteBoard
