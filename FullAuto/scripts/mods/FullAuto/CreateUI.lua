local mod = get_mod("FullAuto")

local firemode_hud_element = {
    package = "packages/ui/views/inventory_background_view/inventory_background_view",
    use_hud_scale = true,
    class_name = "HudElementFullAutoFireMode",
    filename = "FullAuto/scripts/mods/FullAuto/HudElementFullAutoFireMode",
    visibility_groups = {
        "alive",
        "communication_wheel",
        "tactical_overlay"
    }
}
mod:add_require_path(firemode_hud_element.filename)

local _add_hud_element = function(element_pool)
    local found_key, _ = table.find_by_key(element_pool, "class_name", firemode_hud_element.class_name)
    if found_key then
        element_pool[found_key] = firemode_hud_element
    else
        table.insert(element_pool, firemode_hud_element)
    end
end
mod:hook_require("scripts/ui/hud/hud_elements_player_onboarding", _add_hud_element)
mod:hook_require("scripts/ui/hud/hud_elements_player", _add_hud_element)

mod.get_hud_element = function()
    local hud = Managers.ui:get_hud()
    return hud and hud:element(firemode_hud_element.class_name)
end
