local mod = get_mod("KeepSwinging")

local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")

local color_enabled = { 255, 255, 255, 255 }
local color_disabled = { 160, 160, 160, 160 }
local size = { 56, 56 }

local ui_definitions = {
    scenegraph_definition = {
        screen = UIWorkspaceSettings.screen,
        keepswinging_mode_container = {
            parent = "screen",
            vertical_alignment = "bottom",
            horizontal_alignment = "right",
            size = size,
            position = {
                -370,
                -100,
                10
            }
        }
    },
    widget_definitions = {
        keepswinging_mode = UIWidget.create_definition({
            {
                style_id = "icon",
                value_id = "icon",
                pass_type = "texture",
                value = "content/ui/materials/icons/presets/preset_01",
                style = {
                    size = size,
                }
            }
        }, "keepswinging_mode_container")
    }
}

local HudElementKeepSwingingMode = class("HudElementKeepSwingingMode", "HudElementBase")

HudElementKeepSwingingMode.init = function(self, parent, draw_layer, start_scale)
    HudElementKeepSwingingMode.super.init(self, parent, draw_layer, start_scale, ui_definitions)
    self:update_mode(mod.is_in_auto_mode())
    self:update_vis(mod:get("hud_element"))
end

HudElementKeepSwingingMode.update_vis = function(self, vis)
    self._widgets_by_name.keepswinging_mode.style.icon.visible = vis
    self:set_dirty()
end

HudElementKeepSwingingMode.update_mode = function(self, in_auto)
    self._widgets_by_name.keepswinging_mode.style.icon.color = in_auto and color_enabled or color_disabled
    self:set_dirty()
end

return HudElementKeepSwingingMode
