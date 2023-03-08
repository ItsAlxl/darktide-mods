local mod = get_mod("FriendlyNPCs")

return {
	name = "FriendlyNPCs",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "target_opinion",
				type = "dropdown",
				default_value = "likes_character",
				options = {
					{ text = "opinion_likes", value = "likes_character" },
					{ text = "opinion_dislikes", value = "dislikes_character" },
					{ text = "opinion_default", value = "" },
				}
			}
		}
	}
}
