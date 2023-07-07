local mod = get_mod("Shirtless")
local MasterItems = require("scripts/backend/master_items")

local OVERRIDE_SLOT = "slot_gear_upperbody"
local OVERRIDE_ITEM = "content/items/characters/player/human/gear_upperbody/empty_upperbody"

mod:hook(CLASS.PlayerUnitVisualLoadoutExtension, "_equip_item_to_slot", function(func, self, item, slot_name, ...)
    if slot_name == OVERRIDE_SLOT then
        item = MasterItems.get_item(OVERRIDE_ITEM)
    end
    func(self, item, slot_name, ...)
end)

mod:hook(CLASS.UIProfileSpawner, "_change_slot_item", function(func, self, slot_id, item)
    local spawn_data = self._loading_profile_data or self._character_spawn_data
    if slot_id == OVERRIDE_SLOT and spawn_data.profile.character_id == Managers.player:local_player(1)._profile.character_id then
        item = MasterItems.get_item(OVERRIDE_ITEM)
    end
    func(self, slot_id, item)
end)
