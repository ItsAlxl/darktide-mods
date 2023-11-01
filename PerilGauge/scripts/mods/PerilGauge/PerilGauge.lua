local mod = get_mod("PerilGauge")

local hud_element = {
    package = "packages/ui/hud/blocking/blocking",
    use_hud_scale = true,
    class_name = "HudElementPerilGauge",
    filename = "PerilGauge/scripts/mods/PerilGauge/HudElementPerilGauge",
    visibility_groups = {
        "alive",
        "communication_wheel"
    }
}
mod:add_require_path(hud_element.filename)

local _add_hud_element = function(element_pool)
    local found_key, _ = table.find_by_key(element_pool, "class_name", hud_element.class_name)
    if found_key then
        element_pool[found_key] = hud_element
    else
        table.insert(element_pool, hud_element)
    end
end
mod:hook_require("scripts/ui/hud/hud_elements_player_onboarding", _add_hud_element)
mod:hook_require("scripts/ui/hud/hud_elements_player", _add_hud_element)

mod:hook(CLASS.HudElementOvercharge, "update", function(func, self, ...)
    func(self, ...)
    if mod.is_peril_driven ~= nil then
        local widget = mod.is_peril_driven and self._widgets_by_name.overcharge or self._widgets_by_name.overheat
        local text_prefix = mod.is_peril_driven and "" or ""

        if mod.override_alpha and mod.override_alpha > 0 and not widget.visible then
            widget.content.warning_text = text_prefix .. "0%"
            widget.alpha_multiplier = mod.override_alpha * 0.5 -- this 0.5 comes from vanilla peril alpha behavior
            widget.visible = true
        end
        if mod.override_text then
            widget.content.warning_text = text_prefix .. mod.override_text
        end
        if mod.override_color then
            widget.style.warning_text.text_color = table.clone(mod.override_color)
        end
    end
end)

mod:hook(CLASS.HudElementOvercharge, "_update_visibility", function(func, ...)
    return mod.override_alpha or func(...)
end)

--[[ Useful for debugging (h/t Fracticality)
local recreate_hud = function()
    local ui_manager = Managers.ui
    if ui_manager then
        local hud = ui_manager._hud
        if hud then
            local player = Managers.player:local_player(1)
            local peer_id = player:peer_id()
            local local_player_id = player:local_player_id()
            local elements = hud._element_definitions
            local visibility_groups = hud._visibility_groups

            hud:destroy()
            ui_manager:create_player_hud(peer_id, local_player_id, elements, visibility_groups)
        end
    end
end

mod.on_all_mods_loaded = function()
    recreate_hud()
end
--]]
