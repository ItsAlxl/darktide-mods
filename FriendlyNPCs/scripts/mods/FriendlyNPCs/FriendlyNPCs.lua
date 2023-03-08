local mod = get_mod("FriendlyNPCs")
local DialogueBreedSettings = require("scripts/settings/dialogue/dialogue_breed_settings")

local function _get_opinion(npc_class, plr_voice)
    local opinion_settings = DialogueBreedSettings[npc_class].opinion_settings
    local fallback = opinion_settings[plr_voice]
    local opinion = mod:get("target_opinion")
    if opinion ~= "" then
        for _, o in pairs(opinion_settings) do
            if fallback == "" then
                fallback = o
            end
            if o == opinion then
                return o
            end
        end
    end
    return fallback
end

mod:hook_require("scripts/utilities/vo", function(instance)
    mod:hook(instance, "play_local_vo_events", function(func, dialogue_system, vo_rules, voice_profile, wwise_route_key, on_play_callback, seed, is_opinion_vo)
        local unit_extensions = dialogue_system._unit_extension_data
        local vo_unit = nil

        for _, unit_ext in pairs(unit_extensions) do
            if unit_ext._vo_profile_name == voice_profile then
                vo_unit = unit_ext._unit
                break
            end
        end

        if vo_unit then
            local dialogue_extension = ScriptUnit.has_extension(vo_unit, "dialogue_system")

            if dialogue_extension then
                if is_opinion_vo then
                    local local_player = Managers.player:local_player(1)
                    local local_player_unit = local_player.player_unit
                    local player_ext = ScriptUnit.has_extension(local_player_unit, "dialogue_system")

                    if player_ext then
                        local rule = vo_rules[1] .. "_" .. _get_opinion(dialogue_extension._context.class_name, player_ext:get_voice_profile())
                        dialogue_extension:play_local_vo_event(rule, wwise_route_key, nil, seed)
                    end
                else
                    dialogue_extension:play_local_vo_events(vo_rules, wwise_route_key, on_play_callback, seed)
                end
            end

            return vo_unit
        else
            Log.warning("DialogueSystem", "Play Local VO event, no VO unit found for profile %s ", vo_unit)
        end
    end)
    mod:hook(instance, "play_local_vo_event", function(func, unit, rule_name, wwise_route_key, seed, is_opinion_vo)
        local dialogue_extension = ScriptUnit.has_extension(unit, "dialogue_system")

        if dialogue_extension then
            local local_player = Managers.player:local_player(1)
            local local_player_unit = local_player.player_unit
            local player_ext = ScriptUnit.has_extension(local_player_unit, "dialogue_system")

            if player_ext then
                local can_interact = _can_interact(dialogue_extension, local_player_unit)

                if not can_interact then
                    return
                end
            end

            if player_ext and is_opinion_vo then
                rule_name = rule_name .. "_" .. _get_opinion(dialogue_extension._context.class_name, player_ext:get_voice_profile())
            end

            dialogue_extension:play_local_vo_event(rule_name, wwise_route_key, nil, seed)
        end
    end)
end)

