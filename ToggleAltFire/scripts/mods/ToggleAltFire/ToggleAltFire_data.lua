local mod = get_mod("ToggleAltFire")

local sort_options = function(a, b)
	return mod:localize(a.setting_id) < mod:localize(b.setting_id)
end

local create_toggles = function(id_list)
	local toggles = {}
	for i = 1, #id_list do
		toggles[i] = {
			setting_id    = id_list[i],
			type          = "checkbox",
			default_value = true,
		}
	end
	table.sort(toggles, sort_options)
	return toggles
end

return {
	name = "ToggleAltFire",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id  = "optgroup_untoggle_acts",
				type        = "group",
				sub_widgets = {
					{
						setting_id    = "action_reload",
						type          = "checkbox",
						default_value = false,
					},
					{
						setting_id    = "action_start_reload",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "action_vent",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "action_lunge",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "_sprint_base",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "_sprint_staff",
						type          = "checkbox",
						default_value = false,
					},
					{
						setting_id    = "_sprint_blitz",
						type          = "checkbox",
						default_value = false,
					},
					{
						setting_id    = "_sprint_pickup",
						type          = "checkbox",
						default_value = false,
					},
					{
						setting_id    = "action_melee_extra",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "action_shoot_charged",
						type          = "checkbox",
						default_value = false,
					},
					{
						setting_id    = "action_shoot_braced",
						type          = "checkbox",
						default_value = false,
					},
				}
			},
			{
				setting_id  = "optgroup_blitzes",
				type        = "group",
				sub_widgets = create_toggles(mod.blitzes)
			},
			{
				setting_id  = "optgroup_pickups",
				type        = "group",
				sub_widgets = create_toggles(mod.pickups)
			},
			{
				setting_id  = "optgroup_weps",
				type        = "group",
				sub_widgets = create_toggles(mod.weapon_families)
			},
		}
	}
}
