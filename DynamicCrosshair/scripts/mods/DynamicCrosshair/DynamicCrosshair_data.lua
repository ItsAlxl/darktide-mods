local mod = get_mod("DynamicCrosshair")

local widgets = {
	{
		setting_id    = "show_ghost_crosshair",
		type          = "checkbox",
		default_value = false,
	},
	{
		setting_id    = "perspectives_reposition",
		type          = "dropdown",
		default_value = 2,
		options       = {
			{ text = "both",    value = 0 },
			{ text = "only_3p", value = 2 },
			{ text = "only_1p", value = 1 },
			{ text = "never",   value = -1 },
		},
	},
}

local _create_color_channel = function(pfx, channel, default)
	return {
		setting_id = pfx .. "_" .. channel,
		type = "numeric",
		title = channel,
		default_value = default,
		range = { 0, 255 },
	}
end

local _create_color_group = function(group_name, default)
	return {
		setting_id = "group_" .. group_name .. "_rgba",
		type        = "group",
		sub_widgets = {
			_create_color_channel(group_name, "red", default[2]),
			_create_color_channel(group_name, "green", default[3]),
			_create_color_channel(group_name, "blue", default[4]),
			_create_color_channel(group_name, "alpha", default[1]),
		}
	}
end

table.insert(widgets, _create_color_group("villains", {255, 255, 0, 0}))
table.insert(widgets, _create_color_group("heroes", {255, 96, 165, 255}))
table.insert(widgets, _create_color_group("props", {255, 255, 165, 0}))
table.insert(widgets, _create_color_group("ghost", {96, 216, 229, 207}))

return {
	name = "DynamicCrosshair",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = widgets
	}
}
