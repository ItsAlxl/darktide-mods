local mod = get_mod("ConstantFov")
local BASE_MULT = 1.1344640137963142

mod:hook("CameraManager", "_update_camera_properties", function(func, self, camera, shadow_cull_camera, current_node, camera_data, viewport_name)
    if camera_data.vertical_fov then
        Camera.set_vertical_fov(camera, BASE_MULT * self._fov_multiplier)
        Camera.set_vertical_fov(shadow_cull_camera, current_node:default_fov())
        camera_data.vertical_fov = nil
    end
    func(self, camera, shadow_cull_camera, current_node, camera_data, viewport_name)
end)
