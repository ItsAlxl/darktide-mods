local mod = get_mod("Walk")
local Archetypes = require("scripts/settings/archetype/archetypes")

local localization = {
	mod_description = {
		en = "Walk slowly at the push of a button",
		["zh-cn"] = "按下按键时慢走",
	},
	walk_key_toggle = {
		en = "Walk (Toggle)",
		["zh-cn"] = "慢走（开关）",
	},
	walk_key_held = {
		en = "Walk (Held)",
		["zh-cn"] = "慢走（按住）",
	},
	walk_speed = {
		en = "Walk Speed Multiplier",
		["zh-cn"] = "行走速度倍数",
	},
	sprint_cancels = {
		en = "Sprinting cancels walk",
		["zh-cn"] = "疾跑时停止慢走",
	},
}

mod.archetypes = {}

for archetype_name, archetype in pairs(Archetypes) do
	local a = {
		loc = Localize(archetype.archetype_name)
	}
	mod.archetypes[archetype_name] = a
	localization[archetype_name] = { en = a.loc }
end

return localization;
