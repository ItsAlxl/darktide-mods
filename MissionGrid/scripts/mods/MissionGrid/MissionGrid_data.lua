local mod = get_mod("MissionGrid")

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
				range = { 0, 100 },
			},
			{
				setting_id = group_name .. "_y",
				title = "generic_y",
				type = "numeric",
				default_value = default_y,
				range = { 0, 100 },
			},
		}
	}
end

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "group_grid_layout",
				type = "group",
				sub_widgets = {
					{
						setting_id = "start_x",
						type = "numeric",
						default_value = 0,
						range = { -10, 100 },
					},
					{
						setting_id = "start_y",
						type = "numeric",
						default_value = 4,
						range = { -10, 100 },
					},
					{
						setting_id = "spacing_x",
						type = "numeric",
						default_value = 17,
						range = { 10, 60 },
					},
					{
						setting_id = "spacing_y",
						type = "numeric",
						default_value = 17,
						range = { 10, 60 },
					},
					{
						setting_id = "max_columns",
						type = "numeric",
						default_value = 4,
						range = { 1, 8 },
					},
					{
						setting_id = "icon_scale",
						type = "numeric",
						default_value = 1.2,
						range = { 0.5, 2 },
						decimals_number = 1,
					},
				}
			},
			create_position_options("maelstrom", 95, 50),
			create_position_options("static", 80, 69),
			create_position_options("large", 46, 38),
		}
	}
}
