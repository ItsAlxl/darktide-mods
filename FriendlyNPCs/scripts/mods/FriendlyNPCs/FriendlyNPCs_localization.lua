local mod = get_mod("FriendlyNPCs")

local localization = {
	mod_description = {
		en = "Set whether vendors are friendly or mean.",
		["zh-cn"] = "设置 NPC 是否对你友好。",
	},
	opinion_likes = {
		en = "Friendly",
		["zh-cn"] = "友好",
	},
	opinion_dislikes = {
		en = "Mean",
		["zh-cn"] = "恶劣",
	},
	opinion_default = {
		en = "Default",
		["zh-cn"] = "默认",
	},
}

local DialogueBreedSettings = require("scripts/settings/dialogue/dialogue_breed_settings")
mod.opinions = {}
for breed, data in pairs(DialogueBreedSettings) do
	if data.opinion_settings then
		mod.opinions[breed] = data.opinion_settings
		localization[breed] = { en = Localize("loc_npc_short_name_" .. breed .. "_a") }
	end
end

return localization
