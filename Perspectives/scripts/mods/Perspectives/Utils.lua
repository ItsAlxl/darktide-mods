local mod = get_mod("Perspectives")

local camera_handler = nil

mod.get_player = function()
	return Managers.player and Managers.player:local_player(1)
end

mod.get_player_safe = function()
	return Managers.player and Managers.player:local_player_safe(1)
end

mod.get_player_unit = function()
	local plr = mod.get_player()
	return plr and plr.player_unit
end

mod.is_cursor_active = function()
	return Managers.input and Managers.input:cursor_active()
end

mod.get_camera_handler = function()
	if not camera_handler then
		local plr = mod.get_player_safe()
		camera_handler = plr and plr.camera_handler

		if camera_handler then
			mod:hook_safe(camera_handler, "destroy", function(self)
				camera_handler = nil
			end)
		end
	end
	return camera_handler
end
