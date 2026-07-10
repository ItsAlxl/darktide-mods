local mod = get_mod("ToggleAltFire")

local blitz_options = {}
for k, b in pairs(mod.blitz_data) do
	blitz_options[#blitz_options + 1] = {
		setting_id    = k,
		type          = "checkbox",
		default_value = b.default == nil or b.default,
	}
end

local weapon_options = {}
for k, w in pairs(mod.weapon_family_data) do
	weapon_options[#weapon_options + 1] = {
		setting_id    = k,
		type          = "checkbox",
		default_value = w.default == nil or w.default,
	}
end

local sort_options = function(a, b)
	return mod:localize(a.setting_id) < mod:localize(b.setting_id)
end
table.sort(blitz_options, sort_options)
table.sort(weapon_options, sort_options)

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
				sub_widgets = blitz_options
			},
			{
				setting_id  = "optgroup_weps",
				type        = "group",
				sub_widgets = weapon_options
			},
		}
	}
}
