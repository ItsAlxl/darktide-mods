local mod = get_mod("Perspectives")

local FOV_ZOOM = 55
local FOV_NORMAL = 60

local OFFSET_TO_OGRYN = {
    x = 0.0,
    y = -0.75,
    z = -0.1,
}

local _flip_offset = function(offset, flip)
    if flip then
        offset.x = -offset.x
    end
    return offset
end

local _get_shoulder_offset = function(left)
    return _flip_offset({
        x = 0.5,
        y = 0,
        z = 0,
    }, left)
end

local _get_shoulder_zoom_offset = function(left)
    return _flip_offset({
        x = -0.1,
        y = 0.65,
        z = -0.1,
    }, left)
end

local _get_shoulder_ogryn_offset = function(left)
    return _flip_offset({
        x = OFFSET_TO_OGRYN.x + 0.5,
        y = OFFSET_TO_OGRYN.y + 0,
        z = OFFSET_TO_OGRYN.z + 0,
    }, left)
end

local _get_shoulder_zoom_ogryn_offset = function(left)
    return _flip_offset({
        x = -0.1,
        y = 0.65,
        z = 0.0,
    }, left)
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

local _create_node = function(name, offset, fov)
    return {
        near_range = 0.025,
        name = name,
        class = "TransformCamera",
        custom_vertical_fov = fov,
        vertical_fov = fov,
        offset_position = offset
    }
end

local function _alter_third_person_tree(node)
    if node then
        if node._node.name == "third_person" then
            _node_add_child(node, {
                {
                    {
                        {
                            _node = _create_node("pspv_right_zoom_ogryn", _get_shoulder_zoom_ogryn_offset(false), FOV_ZOOM)
                        },
                        _node = _create_node("pspv_right_ogryn", _get_shoulder_ogryn_offset(false))
                    },
                    {
                        _node = _create_node("pspv_right_zoom", _get_shoulder_zoom_offset(false), FOV_ZOOM)
                    },
                    _node = _create_node("pspv_right", _get_shoulder_offset(false))
                },
                {
                    {
                        {
                            _node = _create_node("pspv_left_zoom_ogryn", _get_shoulder_zoom_ogryn_offset(true), FOV_ZOOM)
                        },
                        _node = _create_node("pspv_left_ogryn", _get_shoulder_ogryn_offset(true))
                    },
                    {
                        _node = _create_node("pspv_left_zoom", _get_shoulder_zoom_offset(true), FOV_ZOOM)
                    },
                    _node = _create_node("pspv_left", _get_shoulder_offset(true))
                },
                {
                    {
                        {
                            _node = _create_node("pspv_center_zoom_ogryn", {
                                x = 0.0,
                                y = 1.8,
                                z = -0.2,
                            }, FOV_ZOOM)
                        },
                        _node = _create_node("pspv_center_ogryn", OFFSET_TO_OGRYN)
                    },
                    {
                        _node = _create_node("pspv_center_zoom", {
                            x = 0.0,
                            y = 1.0,
                            z = -0.3,
                        }, FOV_ZOOM)
                    },
                    _node = _create_node("pspv_center", {
                        x = 0.0,
                        y = 0.0,
                        z = 0.2,
                    })
                },
                {
                    {
                        _node = _create_node("pspv_lookaround_ogryn", OFFSET_TO_OGRYN)
                    },
                    _node = _create_node("pspv_lookaround", {
                        x = 0.0,
                        y = -0.5,
                        z = -0.5,
                    })
                },
                _node = _create_node("pspv_root", {
                    x = 0.0,
                    y = 0.5,
                    z = -0.1,
                }, FOV_NORMAL)
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

local _refresh_camera_trees = function()
    local camera_handler = mod.get_camera_handler()
    if camera_handler then
        camera_handler:on_reload()
    end
end
_refresh_camera_trees()
