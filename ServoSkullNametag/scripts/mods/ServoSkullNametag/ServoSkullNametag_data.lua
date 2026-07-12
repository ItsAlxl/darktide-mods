local mod = get_mod("ServoSkullNametag")

local create_skull_icon_options = function()
	return {
		{ text = "icon_choice_blank", value = "" },
		{ text = "icon_choice_skull", value = "" },
		{ text = "icon_choice_toothy", value = "" },
		{ text = "icon_choice_psyker", value = "" },
		{ text = "icon_choice_flame", value = "" },
		{ text = "icon_choice_plus", value = "" },
		{ text = "icon_choice_wrench", value = "" },
		{ text = "icon_choice_dog", value = "" },
	}
end

local create_visibility_options = function()
	return {
		{ text = "vis_choice_all",  value = "all" },
		{ text = "vis_choice_mine", value = "mine" },
		{ text = "vis_choice_none", value = "none" },
	}
end

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "vis_hub",
				type = "dropdown",
				default_value = "mine",
				options = create_visibility_options(),
			},
			{
				setting_id = "vis_mission",
				type = "dropdown",
				default_value = "mine",
				options = create_visibility_options(),
			},
			{
				setting_id = "icon_base",
				title = "skull_base",
				type = "dropdown",
				default_value = "",
				options = create_skull_icon_options(),
			},
			{
				setting_id = "icon_flame",
				title = "skull_flame",
				type = "dropdown",
				default_value = "",
				options = create_skull_icon_options(),
			},
			{
				setting_id = "icon_med",
				title = "skull_med",
				type = "dropdown",
				default_value = "",
				options = create_skull_icon_options(),
			},
		}
	}
}
