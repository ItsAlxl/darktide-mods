local mod = get_mod("PerilGauge")

local ColorUtilities = require("scripts/utilities/ui/colors")

local hud_element = {
	package = "packages/ui/hud/blocking/blocking",
	use_hud_scale = true,
	class_name = "HudElementPerilGauge",
	filename = "PerilGauge/scripts/mods/PerilGauge/HudElementPerilGauge",
	visibility_groups = {
		"alive",
		"communication_wheel"
	}
}
mod:add_require_path(hud_element.filename)

local _add_hud_element = function(element_pool)
	local found_key, _ = table.find_by_key(element_pool, "class_name", hud_element.class_name)
	if found_key then
		element_pool[found_key] = hud_element
	else
		table.insert(element_pool, hud_element)
	end
end
mod:hook_require("scripts/ui/hud/hud_elements_player_onboarding", _add_hud_element)
mod:hook_require("scripts/ui/hud/hud_elements_player", _add_hud_element)

mod.wep_counter_behavior = mod:get("wep_counter_behavior")
mod.wep_counter_vis = false
mod.vanilla_alpha_mult = mod:get("vanilla_alpha_mult")

local hooked_overheat_counter = false

mod:hook(CLASS.HudElementOvercharge, "update", function(func, self, ...)
	func(self, ...)
	local is_peril_driven = mod.is_peril_driven
	if is_peril_driven ~= nil then
		local widget = is_peril_driven and self._widgets_by_name.warp_charge or self._widgets_by_name.overheat
		local widget_content = widget.content
		local text_prefix = mod.is_peril_driven and "" or ""

		local override_alpha = mod.override_alpha
		if override_alpha and override_alpha > 0 and not widget.visible then
			widget_content.warning_text = text_prefix .. "0%"
			widget.alpha_multiplier = override_alpha
			widget.visible = true
		end
		widget.alpha_multiplier = widget.alpha_multiplier and widget.alpha_multiplier * mod.vanilla_alpha_mult

		if mod.override_text then
			widget_content.warning_text = text_prefix .. mod.override_text
		end
		if mod.override_color then
			ColorUtilities.color_copy(mod.override_color, widget.style.warning_text.text_color)
		end
	end
end)

mod:hook(CLASS.HudElementOvercharge, "_update_visibility", function(func, ...)
	return mod.override_alpha or func(...)
end)

mod:hook_require("scripts/ui/hud/elements/weapon_counter/templates/weapon_counter_template_overheat_lockout", function(WeaponCounterOverheat)
	if hooked_overheat_counter then
		return
	end
	hooked_overheat_counter = true

	mod:hook(WeaponCounterOverheat, "update_function", function(func, hud_element_weapon_counter, ui_renderer, widget, is_currently_wielded, weapon_counter_settings, template, dt, t)
		func(hud_element_weapon_counter, ui_renderer, widget, is_currently_wielded, weapon_counter_settings, template, dt, t)
		widget.visible = widget.visible and mod.wep_counter_behavior ~= 1
		mod.wep_counter_vis = widget.visible
	end)
end)

mod:hook_safe(CLASS.HudElementWeaponCounter, "init", function(...)
	mod.wep_counter_vis = false
end)
