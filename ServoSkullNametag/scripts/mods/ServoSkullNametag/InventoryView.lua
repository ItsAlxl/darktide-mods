local mod = get_mod("ServoSkullNametag")

local TextInputPassTemplates = require("scripts/ui/pass_templates/text_input_pass_templates")
local UIWidget = require("scripts/managers/ui/ui_widget")
local Views = require("scripts/ui/views/views")

local tboxes = {}
local focused_tbox_id = nil

-- create textbox definitions
local get_widget_name = function(id)
	return "tbox_servoskull_name_" .. id
end

mod:hook_require("scripts/ui/views/inventory_view/inventory_view_definitions", function(InventoryViewDefinitions)
	local scenegraphs = InventoryViewDefinitions.scenegraph_definition
	local widgets = InventoryViewDefinitions.widget_definitions

	local create_textbox = function(id, y_offset, placeholder)
		local widget_id = get_widget_name(id)
		local scenegraph_id = widget_id .. "_area"
		scenegraphs[scenegraph_id] = {
			vertical_alignment = "center",
			parent = "screen",
			horizontal_alignment = "left",
			size = {
				300,
				40
			},
			position = {
				75,
				50 + y_offset,
				0
			}
		}
		widgets[widget_id] = UIWidget.create_definition(
			table.clone(TextInputPassTemplates.simple_input_field),
			scenegraph_id, {
				placeholder_text = placeholder,
				hide_baseline = true,
			}
		)
		tboxes[id] = {
			widget = nil,
			typing = false,
		}
	end

	create_textbox("base", 0, Localize("loc_talent_cryptic_servo_skull"))
	create_textbox("flame", 50, Localize("loc_talent_cryptic_servo_skull_flamethrower"))
	create_textbox("med", 100, Localize("loc_talent_cryptic_servo_skull_inject_ally"))
end)

local set_is_typing = function(tbox, typing)
	local tbox_widget = tbox and tbox.widget
	if tbox_widget and tbox.typing ~= typing then
		tbox.typing = typing

		local tbox_content = tbox_widget.content
		if tbox_content then
			tbox_content.is_writing = typing
			tbox_content.hide_baseline = not typing
			tbox_content.selected_text = typing and tbox_content.selected_text or nil
			tbox_content._selection_start = typing and tbox_content._selection_start or nil
			tbox_content._selection_end = typing and tbox_content._selection_end or nil
		end
	end
end

local set_focused_tbox = function(focused_id)
	if focused_tbox_id ~= focused_id then
		if focused_tbox_id then
			local previous_tbox = tboxes[focused_tbox_id]
			set_is_typing(previous_tbox, false)

			local previous_widget = previous_tbox.widget
			if previous_widget then
				mod.set_my_skull_name(focused_tbox_id, previous_widget.content.input_text)
			end
		end
		focused_tbox_id = focused_id
		if focused_id then
			local next_tbox = tboxes[focused_id]
			set_is_typing(next_tbox, true)
		end
		Views["inventory_background_view"].close_on_hotkey_pressed = focused_id ~= nil
	end
end

local end_typing = function()
	set_focused_tbox(nil)
end

mod:hook(CLASS.InventoryView, "on_enter", function(func, self, ...)
	func(self, ...)

	local widgets = self._widgets_by_name
	for id, tbox in pairs(tboxes) do
		local w = widgets[get_widget_name(id)]
		tbox.widget = w
		if w then
			local content = w.content
			content.visible = false
			content.input_text = mod.get_skull_name(self._preview_player, id)
		end
	end
end)

mod:hook(CLASS.InventoryView, "on_exit", function(func, self, ...)
	func(self, ...)

	if self._is_own_player then
		for id, tbox in pairs(tboxes) do
			local widget = tbox.widget
			if widget then
				mod.set_my_skull_name(id, widget.content.input_text)
				tbox.widget = nil
			end
		end
	end
end)

mod:hook(CLASS.InventoryView, "_switch_active_layout", function(func, self, tab_context)
	func(self, tab_context)

	local is_cosmetics = tab_context.telemetry_name == "inventory_view_cosmetics"
	for _, tbox in pairs(tboxes) do
		local w = tbox.widget
		if w then
			w.content.visible = is_cosmetics
		end
	end
	end_typing()
end)

mod:hook(CLASS.InventoryView, "update", function(func, self, ...)
	if self._is_own_player then
		for id, tbox in pairs(tboxes) do
			local content = tbox.widget and tbox.widget.content
			if content then
				if content.is_writing and not tbox.typing then
					set_focused_tbox(id)
				end
			end
		end
	else
		for _, tbox in pairs(tboxes) do
			local content = tbox.widget and tbox.widget.content
			if content then
				content.is_writing = false
			end
		end
	end

	return func(self, ...)
end)

mod:hook(CLASS.InventoryView, "_handle_input", function(func, self, input_service)
	if focused_tbox_id ~= nil and (input_service:get("send_chat_message") or input_service:get("back")) then
		end_typing()
	end
	func(self, input_service)
end)

-- prevent hotkey callbacks while typing
local _restrict_cb = function(func, ...)
	if focused_tbox_id == nil then
		func(...)
	end
end
mod:hook(CLASS.InventoryBackgroundView, "cb_on_weapon_swap_pressed", _restrict_cb)
mod:hook(CLASS.ViewElementMenuPanel, "_select_next_tab", _restrict_cb)
