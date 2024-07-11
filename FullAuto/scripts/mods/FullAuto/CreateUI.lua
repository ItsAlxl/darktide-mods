local mod = get_mod("FullAuto")

local CLASS_NAME = "HudElementFullAutoFireMode"

mod:register_hud_element({
	class_name = CLASS_NAME,
	filename = "FullAuto/scripts/mods/FullAuto/HudElementFullAutoFireMode",
	use_hud_scale = true,
	visibility_groups = {
		"alive",
		"communication_wheel",
		"tactical_overlay"
	},
	validation_function = function(params)
		return Managers.state.game_mode:game_mode_name() ~= "hub"
	end
})

mod.get_hud_element = function()
	local hud = Managers.ui:get_hud()
	return hud and hud:element(CLASS_NAME)
end

Managers.package:load("packages/ui/views/inventory_background_view/inventory_background_view", mod.name, nil, true)
