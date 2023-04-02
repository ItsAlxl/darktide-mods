local mod = get_mod("Perspectives")
local CameraTransitionTemplates = require("scripts/settings/camera/camera_transition_templates")
local PlayerUnitStatus = require("scripts/utilities/attack/player_unit_status")

local cycle_includes_center = mod:get("cycle_includes_center")
local aim_mode = mod:get("aim_mode")
local _get_next_shoulder_node = function(previous)
    if aim_mode == 0 and previous then
        if previous == "pspv_zoom_right" then
            return "pspv_zoom_left"
        end
        if previous == "pspv_zoom_left" then
            if cycle_includes_center then
                return "pspv_zoom_center"
            end
            return "pspv_zoom_right"
        end
    end
    if aim_mode == 1 then
        return "pspv_zoom_center"
    end
    return "pspv_zoom_right"
end

local shoulder_node = _get_next_shoulder_node()

local request_3p = true
local temp_disable3p = {}

mod.cycle_shoulder = function()
    shoulder_node = _get_next_shoulder_node(shoulder_node)
end

mod.on_setting_changed = function(id)
    local val = mod:get(id)

    if id == "cycle_includes_center" then
        cycle_includes_center = val
    elseif id == "aim_mode" then
        aim_mode = val
        shoulder_node = _get_next_shoulder_node()
    elseif id == "perspective_transition_time" then
        CameraTransitionTemplates.to_third_person.position.duration = val
        CameraTransitionTemplates.to_first_person.position.duration = val
    end
end

mod.on_setting_changed("perspective_transition_time")

local _get_player = function()
    return Network and Managers.player and Managers.player:local_player(1)
end

local _get_player_unit = function()
    local plr = _get_player()
    return plr and plr.player_unit
end

local _is_3p_temp_disabled = function()
    for _, d in pairs(temp_disable3p) do
        if d then
            return true
        end
    end
    return false
end

local _apply_perspective = function()
    local plr_unit = _get_player_unit()
    if plr_unit then
        local ext = ScriptUnit.has_extension(plr_unit, "first_person_system")
        if ext then
            ext._force_third_person_mode = request_3p and not _is_3p_temp_disabled()
        end
    end
end

local _temp_disable_3p = function(reason, d)
    if not d then
        temp_disable3p[reason] = nil
    else
        temp_disable3p[reason] = d
    end
    _apply_perspective()
end

local _node_get_child_idx = function(node, child_name)
    for i, n in pairs(node) do
        if i ~= "_node" then
            if n._node.name == child_name then
                return i
            end
        end
    end
    return #node + 1
end

local _node_add_child = function(parent, child)
    parent[_node_get_child_idx(parent, child._node.name)] = child
end

local function _alter_third_person_tree(node)
    if node then
        if node._node.name == "third_person" then
            _node_add_child(node, {
                _node = {
                    near_range = 0.025,
                    name = "pspv_zoom_right",
                    class = "TransformCamera",
                    custom_vertical_fov = 65,
                    vertical_fov = 65,
                    offset_position = {
                        z = -0.15,
                        x = 0.4,
                        y = 1.15
                    }
                }
            })
            _node_add_child(node, {
                _node = {
                    near_range = 0.025,
                    name = "pspv_zoom_left",
                    class = "TransformCamera",
                    custom_vertical_fov = 65,
                    vertical_fov = 65,
                    offset_position = {
                        z = -0.15,
                        x = -0.4,
                        y = 1.15
                    }
                }
            })
            _node_add_child(node, {
                _node = {
                    near_range = 0.025,
                    name = "pspv_zoom_center",
                    class = "TransformCamera",
                    custom_vertical_fov = 65,
                    vertical_fov = 65,
                    offset_position = {
                        z = -0.15,
                        x = 0.0,
                        y = 1.5
                    }
                }
            })
        end

        for i, n in pairs(node) do
            if i ~= "_node" then
                _alter_third_person_tree(n)
            end
        end
    end
end

mod:hook_require("scripts/settings/camera/camera_settings", function(CameraSettings)
    _alter_third_person_tree(CameraSettings.player_third_person)
end)

mod:hook_safe(CLASS.PlayerUnitWeaponExtension, "on_slot_wielded", function(self, slot_name, ...)
    _temp_disable_3p("device", slot_name == "slot_device")
end)

mod.toggle_third_person = function()
    request_3p = not request_3p
    _apply_perspective()
end

mod:hook(CLASS.MissionManager, "force_third_person_mode", function(func, self)
    local mode = mod:get("default_perspective_mode")

    if mode == -1 then
        request_3p = not func(self)
    elseif mode == 0 then
        request_3p = func(self)
    elseif mode == 1 then
        request_3p = false
    elseif mode == 2 then
        request_3p = true
    end

    return request_3p
end)

local NODE_IGNORE_SCALED_TRANSFORM_OFFSETS = {
    consumed = true
}
local NODE_OBJECT_NAMES = {
    consumed = "j_hips"
}
mod:hook(CLASS.PlayerUnitCameraExtension, "_evaluate_camera_tree", function(func, self)
    -- modified from scripts/extension_systems/camera/player_unit_camera_extension
    local wants_first_person_camera = self._first_person_extension:wants_first_person_camera()
    local character_state_component = self._character_state_component
    local assisted_state_input_component = self._assisted_state_input_component
    local sprint_character_state_component = self._sprint_character_state_component
    local disabling_type = self._disabled_character_state_component.disabling_type
    local is_ledge_hanging = PlayerUnitStatus.is_ledge_hanging(character_state_component)
    local is_assisted = PlayerUnitStatus.is_assisted(assisted_state_input_component)
    local is_pounced = disabling_type == "pounced"
    local is_netted = disabling_type == "netted"
    local is_warp_grabbed = disabling_type == "warp_grabbed"
    local is_mutant_charged = disabling_type == "mutant_charged"
    local is_grabbed = disabling_type == "grabbed"
    local is_consumed = disabling_type == "consumed"
    local alternate_fire_is_active = self._alternate_fire_component.is_active
    local tree, node = nil

    _temp_disable_3p("aim", alternate_fire_is_active and aim_mode == 2)

    if wants_first_person_camera then
        local wants_sprint_camera = sprint_character_state_component.wants_sprint_camera
        local sprint_overtime = sprint_character_state_component.sprint_overtime
        local have_sprint_over_time = sprint_overtime and sprint_overtime > 0
        local is_lunging = self._lunge_character_state_component.is_lunging

        if is_assisted then
            node = "first_person_assisted"
        elseif alternate_fire_is_active then
            node = "aim_down_sight"
        elseif wants_sprint_camera and have_sprint_over_time then
            node = "sprint_overtime"
        elseif wants_sprint_camera then
            node = "sprint"
        elseif is_lunging then
            node = "lunge"
        else
            node = "first_person"
        end

        tree = "first_person"
    elseif self._use_third_person_hub_camera then
        tree = "third_person_hub"

        if self._breed.name == "ogryn" then
            node = "third_person_ogryn"
        else
            node = "third_person_human"
        end
    else
        local is_disabled, requires_help = PlayerUnitStatus.is_disabled(character_state_component)
        local is_hogtied = PlayerUnitStatus.is_hogtied(character_state_component)

        if is_hogtied then
            node = "hogtied"
        elseif is_ledge_hanging then
            node = "ledge_hanging"
        elseif is_pounced or is_netted or is_warp_grabbed or is_mutant_charged or is_grabbed then
            node = "pounced"
        elseif is_consumed then
            node = "consumed"
        elseif is_disabled and requires_help then
            node = "disabled"
        elseif alternate_fire_is_active then
            node = shoulder_node
        else
            node = "third_person"
        end

        tree = "third_person"
    end

    local camera_tree_component = self._camera_tree_component
    camera_tree_component.tree = tree
    camera_tree_component.node = node
    self._tree = tree
    self._node = node
    local object_name = NODE_OBJECT_NAMES[node]
    local object = nil

    if object_name then
        object = Unit.node(self._unit, object_name)
    end

    self._object = object
    local ignore_offset = NODE_IGNORE_SCALED_TRANSFORM_OFFSETS[node]

    if self._ignore_offset ~= ignore_offset then
        local player_unit_spawn_manager = Managers.state.player_unit_spawn
        local player = player_unit_spawn_manager:owner(self._unit)

        if player:is_human_controlled() then
            local viewport_name = player.viewport_name

            if viewport_name then
                Managers.state.camera:set_variable(viewport_name, "ignore_offset", ignore_offset)
            end
        end
    end

    self._ignore_offset = ignore_offset
end)

--[[
local _refresh_camera_trees = function()
    local plr = _get_player()
    if plr then
        plr.camera_handler:on_reload()
    end
end
_refresh_camera_trees()
--]]
