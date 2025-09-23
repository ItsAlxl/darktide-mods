local mod = get_mod("NoNews")

mod:hook(CLASS.ViewElementNewsSlide, "_initialize_slides", function(self, ...)
	self:set_visibility(false)
end)
