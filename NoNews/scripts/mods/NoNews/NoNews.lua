local mod = get_mod("NoNews")

mod:hook_safe(CLASS.MainMenuView, "on_enter", function(self)
    self._news_element._visible = false
end)
