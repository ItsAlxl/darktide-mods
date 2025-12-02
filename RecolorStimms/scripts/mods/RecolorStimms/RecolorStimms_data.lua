local mod = get_mod("RecolorStimms")

mod.stimm_data = {}

mod.register_stimm = function(stimm_name, default_color, default_decal_idx)
	mod.stimm_data[stimm_name] = {
		default_color = default_color,
		custom_color = table.clone(default_color),
		default_decal = default_decal_idx,
		custom_decal = default_decal_idx,
	}
end
mod.register_stimm("syringe_corruption_pocketable", { 0.15, 0.8, 0.1 }, 1)
mod.register_stimm("syringe_speed_boost_pocketable", { 0.0, 0.25, 0.75 }, 2)
mod.register_stimm("syringe_power_boost_pocketable", { 0.9, 0.2, 0.1 }, 3)
mod.register_stimm("syringe_ability_boost_pocketable", { 0.9, 0.5, 0.05 }, 4)
mod.register_stimm("syringe_broker_pocketable", { 0.9, 0.2, 0.1 }, 3)

local _create_color_channel = function(channel_prefix, channel, default)
	return {
		setting_id = channel_prefix .. "_" .. channel,
		type = "numeric",
		title = channel,
		default_value = default,
		range = { 0, 255 },
	}
end

local _create_stimm_group = function(group_name, data)
	local math_floor = math.floor
	return {
		setting_id  = group_name,
		type        = "group",
		sub_widgets = {
			_create_color_channel(group_name, "red", math_floor(255 * data.default_color[1])),
			_create_color_channel(group_name, "green", math_floor(255 * data.default_color[2])),
			_create_color_channel(group_name, "blue", math_floor(255 * data.default_color[3])),
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

local reset_options = {
	{ text = "reset_none", value = "" }
}
local widgets = {
	{
		setting_id    = "reset",
		type          = "dropdown",
		default_value = "",
		options       = reset_options,
	}
}
for name, data in pairs(mod.stimm_data) do
	table.insert(widgets, _create_stimm_group(name, data))
	table.insert(reset_options, { text = name, value = name })
end

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = widgets
	}
}
