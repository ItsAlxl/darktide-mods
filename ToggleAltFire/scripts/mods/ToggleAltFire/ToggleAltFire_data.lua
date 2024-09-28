local mod = get_mod("ToggleAltFire")

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
				sub_widgets = {
					{
						setting_id    = "psyker_smite",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "psyker_chain_lightning",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "psyker_throwing_knives",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "frag_grenade",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "krak_grenade",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "smoke_grenade",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "shock_grenade",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "fire_grenade",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "zealot_throwing_knives",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "ogryn_grenade_box",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "ogryn_grenade_box_cluster",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "ogryn_grenade_frag",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "ogryn_grenade_friend_rock",
						type          = "checkbox",
						default_value = true,
					},
				}
			},
			{
				setting_id  = "optgroup_weps",
				type        = "group",
				sub_widgets = {
					{
						setting_id    = "autogun",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "autopistol",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "lasgun",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "laspistol",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "stub_rifle",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "stub_pistol",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "shotgun",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "rippergun",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "bolter",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "heavystubber",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "grenadier_gauntlet",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "shotgun_grenade",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "plasma_rifle",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "flamer",
						type          = "checkbox",
						default_value = true,
					},
					{
						setting_id    = "force_staff",
						type          = "checkbox",
						default_value = true,
					},
				}
			},
		}
	}
}
