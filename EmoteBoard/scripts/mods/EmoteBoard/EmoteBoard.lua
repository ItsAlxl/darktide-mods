local mod = get_mod("EmoteBoard")

mod:register_hud_element({
	class_name = "HudElementEmoteBoard",
	filename = "EmoteBoard/scripts/mods/EmoteBoard/HudElementEmoteBoard",
	use_hud_scale = true,
	visibility_groups = {
		"alive",
		"emote_wheel",
	},
	validation_function = function(params)
		return Managers.state.game_mode:game_mode_name() == "hub"
	end
})

mod.get_board = function()
	local hud = Managers.ui:get_hud()
	return hud and hud:element("HudElementEmoteBoard")
end

mod._kb_toggle_show = function(held)
	local board = mod.get_board()
	if board then
		board:set_visibility()
	end
end

mod:hook(CLASS.UIHud, "emote_wheel_wants_camera_control", function(func, self)
	return mod.take_camera_control or func(self)
end)
