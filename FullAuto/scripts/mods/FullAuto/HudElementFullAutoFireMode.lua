local mod = get_mod("FullAuto")

local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")

local color_enabled = { 255, 255, 255, 255 }
local color_disabled = { 160, 160, 160, 160 }
local size = { 56, 56 }

local ui_definitions = {
    scenegraph_definition = {
        screen = UIWorkspaceSettings.screen,
        fullauto_mode_container = {
            parent = "screen",
            vertical_alignment = "bottom",
            horizontal_alignment = "right",
            size = size,
            position = {
                -370,
                -30,
                10
            }
        }
    },
    widget_definitions = {
        fullauto_mode = UIWidget.create_definition({
            {
                style_id = "icon",
                value_id = "icon",
                pass_type = "texture",
                value = "content/ui/materials/icons/presets/preset_16",
                style = {
                    size = size,
                }
            }
        }, "fullauto_mode_container")
    }
}

local HudElementFullAutoFireMode = class("HudElementFullAutoFireMode", "HudElementBase")

HudElementFullAutoFireMode.init = function(self, parent, draw_layer, start_scale)
    HudElementFullAutoFireMode.super.init(self, parent, draw_layer, start_scale, ui_definitions)
    self:update_firemode(mod.is_in_autofire_mode())
    self:update_vis(mod:get("hud_element"))
end

HudElementFullAutoFireMode.update_vis = function(self, vis)
    self._widgets_by_name.fullauto_mode.style.icon.visible = vis
    self:set_dirty()
end

HudElementFullAutoFireMode.update_firemode = function(self, in_auto)
    self._widgets_by_name.fullauto_mode.style.icon.color = in_auto and color_enabled or color_disabled
    self:set_dirty()
end

return HudElementFullAutoFireMode
