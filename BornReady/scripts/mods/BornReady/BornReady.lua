local mod = get_mod("BornReady")

mod:hook_safe("LobbyView", "on_enter", function(self)
	self:_set_own_player_ready_status(true)
end)
