local mod = get_mod("Click2Play")

mod:hook("MainMenuView", "_handle_input", function(func, self, ...)
	local selected_idx = self._selected_character_list_index
    if selected_idx then
        if self._character_list_widgets[selected_idx].content.hotspot.on_pressed then
            self:_on_play_pressed()
        end
    end

    func(self, ...)
end)
