local mod = get_mod("PickForMe")
local ItemUtils = require("scripts/utilities/items")
local PlayerProgressionUnlocks = require("scripts/settings/player/player_progression_unlocks")

local SlotName = {
    PRIMARY = "slot_primary",
    SECONDARY = "slot_secondary",
    CURIO = "slot_attachment_1",
    CURIO_1 = "slot_attachment_1",
    CURIO_2 = "slot_attachment_2",
    CURIO_3 = "slot_attachment_3",
}

mod:hook("StateMainMenu", "on_enter", function(func, self, parent, params, creation_context)
    if mod:get("random_character") then
        params.selected_profile = math.random_array_entry(params.profiles)
    end
    func(self, parent, params, creation_context)
end)

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

local _get_player = function()
    local valid_gamemode = true
    if Managers.state and Managers.state.game_mode then
        local gm_name = Managers.state.game_mode:game_mode_name()
        valid_gamemode = gm_name == "hub" or gm_name == "shooting_range"
    end
    if valid_gamemode and Managers.player then
        return Managers.player:local_player(1)
    end
    return nil
end

local function _randomize_loadout(slot_filter, random_talents)
    local player = _get_player()
    if not player then
        if mod:get("msg_invalid") then
            mod:echo(mod:localize("bad_circumstance"))
        end
        return
    end

    local character_id = player:character_id()
    local profile = player:profile()
    local plr_level = profile.current_level

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
    if random_talents == nil then
        random_talents = mod:get("random_talents")
    end

    if random_talents then
        local talent_groups = profile.archetype.specializations[profile.specialization].talent_groups
        local selected_talents = {}
        for _, group in pairs(talent_groups) do
            if not (group.non_selectable_group or group.required_level > plr_level) then
                selected_talents[math.random_array_entry(group.talents)] = true
            end
        end
        
        -- Select talents
        Managers.data_service.talents:set_talents(player, selected_talents)
        -- Update talent view
        Managers.event:trigger("event_on_profile_preset_changed", selected_talents)
    end

    if #slot_filter > 0 then
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
                    if plr_level >= PlayerProgressionUnlocks.gadget_slot_1 then
                        _equip_item_from_pool(gear_pools, slot, SlotName.CURIO_1)
                    end
                    if plr_level >= PlayerProgressionUnlocks.gadget_slot_2 then
                        _equip_item_from_pool(gear_pools, slot, SlotName.CURIO_2)
                    end
                    if plr_level >= PlayerProgressionUnlocks.gadget_slot_3 then
                        _equip_item_from_pool(gear_pools, slot, SlotName.CURIO_3)
                    end
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
    _randomize_loadout()
end

mod:command("pickforme", mod:localize("cmd_desc"), function(...)
    local slot_filter = nil
    local talents = false

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
            talents = true
        else
            if table.contains(args, "gear") then
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
            if table.contains(args, "talents") then
                talents = true
            end
        end
    end

    _randomize_loadout(slot_filter, talents)
end)
