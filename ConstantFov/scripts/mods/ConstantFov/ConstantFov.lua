local mod = get_mod("ConstantFov")

local DEFAULT_BASE_MULT = 1.1344640137963142
local VeteranAbilities = require("scripts/settings/ability/player_abilities/veteran_abilities")

local vet_ult_buffs = {}
for _, ab in pairs(VeteranAbilities) do
    if ab.ability_template_tweak_data and ab.ability_template_tweak_data.buff_to_add and ab.ability_type and ab.ability_type == "combat_ability" then
        table.insert(vet_ult_buffs, ab.ability_template_tweak_data.buff_to_add)
    end
end

local fov_data = {
    base = mod:get("apply_baseline") and DEFAULT_BASE_MULT or 1.0,
    change_multiplier = mod:get("change_multiplier"),
    limit_lower = mod:get("limit_lower"),
    limit_upper = mod:get("limit_upper"),
    allow_vetult = mod:get("allow_vetult"),
}

local allow_nodes = {
    aim_down_sight = mod:get("allow_aim"),
    sprint = mod:get("allow_sprint"),
    sprint_overtime = mod:get("allow_sprint"),
    lunge = mod:get("allow_lunge"),
}

mod.on_setting_changed = function(id)
    local val = mod:get(id)
    if id == "allow_aim" then
        allow_nodes.aim_down_sight = val
    elseif id == "allow_sprint" then
        allow_nodes.sprint = val
        allow_nodes.sprint_overtime = val
    elseif id == "allow_lunge" then
        allow_nodes.lunge = val
    elseif id == "apply_baseline" then
        fov_data.base = val and DEFAULT_BASE_MULT or 1.0
    elseif fov_data[id] ~= nil then
        fov_data[id] = val
    end
end

mod:hook(CLASS.CameraManager, "_update_camera_properties", function(func, self, camera, shadow_cull_camera, current_node, camera_data, ...)
    if camera_data.vertical_fov then
        local check = allow_nodes[current_node._name]
        if check == nil or check then
            camera_data.vertical_fov = fov_data.base * math.clamp(1.0 + fov_data.change_multiplier * ((camera_data.vertical_fov / DEFAULT_BASE_MULT) - 1.0), fov_data.limit_lower, fov_data.limit_upper)
        else
            camera_data.vertical_fov = fov_data.base
        end
    end
    func(self, camera, shadow_cull_camera, current_node, camera_data, ...)
end)

mod:hook(CLASS.Buff, "update_stat_buffs", function(func, self, current_stat_buffs, ...)
    func(self, current_stat_buffs, ...)
    if not fov_data.allow_vetult then
        local fov_multiplier = current_stat_buffs.fov_multiplier
        if fov_multiplier and table.contains(vet_ult_buffs, self:template_name()) then
            current_stat_buffs.fov_multiplier = 1
        end
    end
end)

mod:hook_require("scripts/settings/camera/camera_transition_templates", function(CameraTransitionTemplates)
    mod:hook(CameraTransitionTemplates.from_sprint.vertical_fov, "transition_func", function(func, t)
        if allow_nodes.sprint then
            return func(t)
        end
        return 1.0
    end)

    mod:hook(CameraTransitionTemplates.from_lunge.vertical_fov, "transition_func", function(func, t)
        if allow_nodes.lunge then
            return func(t)
        end
        return 1.0
    end)

    mod:hook(CameraTransitionTemplates.zoom.vertical_fov, "transition_func", function(func, t)
        if allow_nodes.aim_down_sight then
            return func(t)
        end
        return 1.0
    end)
end)
