local mod = get_mod("ConstantFov")

mod:hook("CameraManager", "_update_camera_properties", function(func, self, camera, shadow_cull_camera, current_node, camera_data, viewport_name)
    if camera_data.vertical_fov then
        Camera.set_vertical_fov(camera, self._fov_multiplier)
        Camera.set_vertical_fov(shadow_cull_camera, current_node:default_fov())
        camera_data.vertical_fov = nil
    end
    func(self, camera, shadow_cull_camera, current_node, camera_data, viewport_name)
end)
