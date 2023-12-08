local mod = get_mod("RecolorStimms")
local SyringeCaseColor = require("scripts/components/syringe_case_color")

mod.get_stimm_color = function(stimm_name)
    return mod.stimm_data[stimm_name].custom_color
end

mod.set_stimm_color = function(stimm_name, color)
    local custom_color = mod.stimm_data[stimm_name].custom_color
    if color then
        mod:set(stimm_name .. "_red", color[1])
        mod:set(stimm_name .. "_green", color[2])
        mod:set(stimm_name .. "_blue", color[3])
        custom_color[1] = color[1]
        custom_color[2] = color[2]
        custom_color[3] = color[3]
    else
        custom_color[1] = mod:get(stimm_name .. "_red")
        custom_color[2] = mod:get(stimm_name .. "_green")
        custom_color[3] = mod:get(stimm_name .. "_blue")
    end
end

mod.get_stimm_decal_index = function(stimm_name)
    return mod.stimm_data[stimm_name].custom_decal
end

mod.set_stimm_decal_index = function(stimm_name, idx)
    if idx then
        mod:set(stimm_name .. "_decal", idx)
    else
        idx = mod:get(stimm_name .. "_decal")
    end
    mod.stimm_data[stimm_name].custom_decal = idx
end

mod.refresh_all_colors = function()
    for name, _ in pairs(mod.stimm_data) do
        mod.set_stimm_color(name)
    end
end

mod.refresh_all_decals = function()
    for name, _ in pairs(mod.stimm_data) do
        mod.set_stimm_decal_index(name)
    end
end

mod.on_setting_changed = function(id)
    mod.refresh_all_colors()
    mod.refresh_all_decals()
end
mod.on_setting_changed()

mod:hook(CLASS.SyringeEffects, "_set_color", function(func, self)
    local weapon_template_name = self._weapon_template.name
    local custom_color = mod.get_stimm_color(weapon_template_name)
    local color_vec3 = Vector3(custom_color[1], custom_color[2], custom_color[3])
    local decal_index = mod.stimm_data[weapon_template_name].custom_decal
    local unit_components = self._unit_components
    local num_components = #unit_components

    for i = 1, num_components do
        local syringe_color = unit_components[i]
        local color_component = syringe_color.component
        color_component:set_colors(syringe_color.unit, color_vec3, color_vec3)
        color_component:set_decal(syringe_color.unit, decal_index)
    end
end)

mod:hook(SyringeCaseColor.events, "set_colors", function(func, self, pickup_settings)
    local custom_color = mod.get_stimm_color(pickup_settings.name)
    local color_vec3 = Vector3(custom_color[1], custom_color[2], custom_color[3])

    self:_set_colors(self._unit, color_vec3, color_vec3, 1)
end)
