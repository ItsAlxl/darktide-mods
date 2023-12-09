local mod = get_mod("RecolorStimms")

mod.get_stimm_color = function(stimm_name)
    local stimm_data = mod.stimm_data[stimm_name]
    return stimm_data and stimm_data.custom_color
end

mod.get_stimm_color_default = function(stimm_name)
    local stimm_data = mod.stimm_data[stimm_name]
    return stimm_data and stimm_data.default_color
end

mod.get_stimm_argb_255 = function(stimm_name)
    local custom_color = mod.get_stimm_color(stimm_name)
    local math_floor = math.floor
    return custom_color and { 255,
        math_floor(custom_color[1] * 255),
        math_floor(custom_color[2] * 255),
        math_floor(custom_color[3] * 255)
    }
end

mod.set_stimm_color = function(stimm_name, color)
    local stimm_data = mod.stimm_data[stimm_name]
    if not stimm_data then
        return
    end

    local custom_color = stimm_data.custom_color
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

mod.reset_stimm_color_to_default = function(stimm_name)
    mod.set_stimm_color(stimm_name, mod.get_stimm_color_default(stimm_name))
end

mod.get_stimm_decal_index = function(stimm_name)
    local stimm_data = mod.stimm_data[stimm_name]
    return stimm_data.custom_decal
end

mod.get_stimm_decal_index_default = function(stimm_name)
    local stimm_data = mod.stimm_data[stimm_name]
    return stimm_data.default_decal
end

mod.set_stimm_decal_index = function(stimm_name, idx)
    local stimm_data = mod.stimm_data[stimm_name]
    if not stimm_data then
        return
    end

    if idx then
        mod:set(stimm_name .. "_decal", idx)
    else
        idx = mod:get(stimm_name .. "_decal")
    end
    stimm_data.custom_decal = idx
end

mod.reset_stimm_decal_index_to_default = function(stimm_name)
    mod.set_stimm_decal_index(stimm_name, mod.get_stimm_decal_index_default(stimm_name))
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

local _refresh_all = function()
    mod.refresh_all_colors()
    mod.refresh_all_decals()
end
_refresh_all()

mod.on_setting_changed = function(id)
    if id == "reset" then
        local stimm_to_reset = mod:get(id)
        if mod.stimm_data[stimm_to_reset] then
            mod.reset_stimm_color_to_default(stimm_to_reset)
            mod.reset_stimm_decal_index_to_default(stimm_to_reset)
        end
        mod:set(id, "")
    else
        _refresh_all()
    end
end

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

mod:hook_require("scripts/components/syringe_case_color", function(SyringeCaseColor)
    mod:hook(SyringeCaseColor.events, "set_colors", function(func, self, pickup_settings)
        local custom_color = mod.get_stimm_color(pickup_settings.name)
        local color_vec3 = Vector3(custom_color[1], custom_color[2], custom_color[3])

        self:_set_colors(self._unit, color_vec3, color_vec3, 1)
    end)
end)
