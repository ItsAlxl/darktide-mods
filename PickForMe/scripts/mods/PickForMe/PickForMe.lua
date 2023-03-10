local mod = get_mod("PickForMe")
local ItemUtils = require("scripts/utilities/items")

local SlotName = {
    PRIMARY = "slot_primary",
    SECONDARY = "slot_secondary",
    CURIO = "slot_attachment_1",
    CURIO_1 = "slot_attachment_1",
    CURIO_2 = "slot_attachment_2",
    CURIO_3 = "slot_attachment_3",
}

local _equip_item_from_pool = function(pools, pool_slot, equip_slot)
    local item = math.random_array_entry(pools[pool_slot])
    if item then
        for _, p in pairs(pools) do
            local idx = table.find(p, item)
            if idx ~= nil then
                table.remove(p, idx)
            end
        end

        if not equip_slot then
            equip_slot = pool_slot
        end

        -- Equip item
        ItemUtils.equip_item_in_slot(equip_slot, item)
        -- Update inventory view
        Managers.event:trigger("event_inventory_view_equip_item", equip_slot, item)
    end
end

local _get_character_id = function()
    local valid_gamemode = true
    if Managers.state and Managers.state.game_mode then
        local gm_name = Managers.state.game_mode:game_mode_name()
        valid_gamemode = gm_name == "hub" or gm_name == "shooting_range"
    end
    if valid_gamemode and Managers.player and Managers.player:local_player(1) then
        return Managers.player:local_player(1):character_id()
    end
    return ""
end

local function _randomize_gear(slot_filter)
    local character_id = _get_character_id()
    if character_id == "" then
        mod:echo(mod:localize("only_use_in_hub"))
    else
        if slot_filter == nil then
            slot_filter = {}
            if mod:get("random_primary") then
                table.insert(slot_filter, SlotName.PRIMARY)
            end
            if mod:get("random_secondary") then
                table.insert(slot_filter, SlotName.SECONDARY)
            end
            if mod:get("random_curios") then
                table.insert(slot_filter, SlotName.CURIO)
            end
        end

        Managers.data_service.gear:fetch_inventory(character_id, slot_filter):next(function(items)
            local gear_pools = {
                [SlotName.PRIMARY] = {},
                [SlotName.SECONDARY] = {},
                [SlotName.CURIO] = {},
            }
            for _, item in pairs(items) do
                for _, slot in pairs(item.slots) do
                    if gear_pools[slot] then
                        table.insert(gear_pools[slot], item)
                    end
                end
            end

            for slot, _ in pairs(gear_pools) do
                if slot == SlotName.CURIO then
                    _equip_item_from_pool(gear_pools, slot, SlotName.CURIO_1)
                    _equip_item_from_pool(gear_pools, slot, SlotName.CURIO_2)
                    _equip_item_from_pool(gear_pools, slot, SlotName.CURIO_3)
                else
                    _equip_item_from_pool(gear_pools, slot)
                end
            end
        end):catch(function(errors)
            mod:error(mod:localize("catch_error"))
            for k, v in pairs(errors) do
                mod:error("%s: %s", k, v)
            end
        end)
    end
end

mod.quick_randomize = function()
    _randomize_gear()
end

mod:command("pickforme", mod:localize("cmd_desc"), function(...)
    local slot_filter = nil

    local args = { ... }
    if #args > 0 then
        if table.contains(args, "help") then
            mod:echo(mod:localize("cmd_help"))
            return
        end

        slot_filter = {}
        if table.contains(args, "all") then
            table.insert(slot_filter, SlotName.PRIMARY)
            table.insert(slot_filter, SlotName.SECONDARY)
            table.insert(slot_filter, SlotName.CURIO)
        else
            if table.contains(args, "weapons") then
                table.insert(slot_filter, SlotName.PRIMARY)
                table.insert(slot_filter, SlotName.SECONDARY)
            else
                if table.contains(args, "primary") then
                    table.insert(slot_filter, SlotName.PRIMARY)
                end
                if table.contains(args, "secondary") then
                    table.insert(slot_filter, SlotName.SECONDARY)
                end
            end
            if table.contains(args, "curios") then
                table.insert(slot_filter, SlotName.CURIO)
            end
        end
    end

    _randomize_gear(slot_filter)
end)
