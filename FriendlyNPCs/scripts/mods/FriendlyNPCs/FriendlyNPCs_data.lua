local mod = get_mod("FriendlyNPCs")

local opinion_opts = {
	{ text = "opinion_likes",    value = "likes_character" },
	{ text = "opinion_dislikes", value = "dislikes_character" },
	{ text = "opinion_default",  value = "" },
}

local widgets = {}
for breed, _ in pairs(mod.opinions) do
	table.insert(widgets, {
		setting_id = breed,
		type = "dropdown",
		default_value = "likes_character",
		options = table.clone(opinion_opts)
	})
end

return {
	name = "FriendlyNPCs",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = widgets
	}
}
