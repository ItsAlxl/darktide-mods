local mod = get_mod("LoadoutNames")

local create_position_options = function(group_name, default_x, default_y)
	return {
		setting_id = "group_" .. group_name,
		type = "group",
		sub_widgets = {
			{
				setting_id = group_name .. "_x",
				title = "generic_x",
				type = "numeric",
				default_value = default_x,
				range = { -1920, 0 },
			},
			{
				setting_id = group_name .. "_y",
				title = "generic_y",
				type = "numeric",
				default_value = default_y,
				range = { 0, 1080 },
			},
		}
	}
end

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = false,
	options = {
		widgets = {
			create_position_options("tbox", -75, 50),
			create_position_options("tooltip", 0, 150),
		}
	}
}
