local mod = get_mod("RecolorStimms")

mod.stimm_data = {
	syringe_corruption_pocketable = {
		default_color = { 0.15, 0.8, 0.1 },
		custom_color = { 0.15, 0.8, 0.1 },
		default_decal = 1,
		custom_decal = 1,
	},
	syringe_ability_boost_pocketable = {
		default_color = { 0.9, 0.5, 0.05 },
		custom_color = { 0.9, 0.5, 0.05 },
		default_decal = 4,
		custom_decal = 4,
	},
	syringe_power_boost_pocketable = {
		default_color = { 0.9, 0.2, 0.1 },
		custom_color = { 0.9, 0.2, 0.1 },
		default_decal = 3,
		custom_decal = 3,
	},
	syringe_speed_boost_pocketable = {
		default_color = { 0.0, 0.25, 0.75 },
		custom_color = { 0.0, 0.25, 0.75 },
		default_decal = 2,
		custom_decal = 2,
	},
}

local _create_color_channel = function(channel_prefix, channel, default)
	return {
		setting_id = channel_prefix .. "_" .. channel,
		type = "numeric",
		title = channel,
		default_value = default,
		decimals_number = 2,
		range = { 0, 1 },
	}
end

local _create_stimm_group = function(group_name, data)
	return {
		setting_id  = group_name,
		type        = "group",
		sub_widgets = {
			_create_color_channel(group_name, "red", data.default_color[1]),
			_create_color_channel(group_name, "green", data.default_color[2]),
			_create_color_channel(group_name, "blue", data.default_color[3]),
			{
				setting_id    = group_name .. "_decal",
				title         = "decal",
				type          = "dropdown",
				default_value = data.default_decal,
				options       = {
					{ text = "syringe_corruption_pocketable",    value = 1 },
					{ text = "syringe_speed_boost_pocketable",   value = 2 },
					{ text = "syringe_power_boost_pocketable",   value = 3 },
					{ text = "syringe_ability_boost_pocketable", value = 4 },
				},
			},
		}
	}
end

local widgets = {}
for name, data in pairs(mod.stimm_data) do
	table.insert(widgets, _create_stimm_group(name, data))
end

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = widgets
	}
}
