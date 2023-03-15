local mod = get_mod("TagKeys")
local Vo = require("scripts/utilities/vo")

local Tagger = nil

mod:hook_safe("HudElementSmartTagging", "init", function(self, ...)
    Tagger = self
end)

mod:hook_safe("HudElementSmartTagging", "destroy", function(self, ...)
    if Tagger == self then
        Tagger = nil
    end
end)

local _find_wheel_option = function(display_name)
    for _, entry in pairs(Tagger._entries) do
        if entry and entry.option and entry.option.display_name == display_name then
            return entry.option
        end
    end
    return nil
end

local _force_tag = function(display_name)
    if not Tagger then
        return
    end

    local option = _find_wheel_option(display_name)
    if not option then
        return
    end

    -- taken from "scripts/ui/hud/elements/smart_tagging/hud_element_smart_tagging"
    local tag_type = option.tag_type

    if tag_type then
        local force_update_targets = true
        local raycast_data = Tagger:_find_raycast_targets(force_update_targets)
        local hit_position = raycast_data.static_hit_position

        if hit_position then
            Tagger:_trigger_smart_tag(tag_type, nil, Vector3Box.unbox(hit_position))
        end
    end

    local chat_message_data = option.chat_message_data

    if chat_message_data then
        local text = chat_message_data.text
        local channel_tag = chat_message_data.channel
        local channel, channel_handle = Tagger:_get_chat_channel_by_tag(channel_tag)

        if channel then
            Managers.chat:send_loc_channel_message(channel_handle, text, nil)
        end
    end

    local voice_event_data = option.voice_event_data

    if voice_event_data then
        local parent = Tagger._parent
        local player_unit = parent:player_unit()

        if player_unit then
            Vo.on_demand_vo_event(player_unit, voice_event_data.voice_tag_concept, voice_event_data.voice_tag_id)
        end
    end

    Managers.telemetry_reporters:reporter("com_wheel"):register_event(option.voice_event_data.voice_tag_id)
end

mod.tag_thanks = function()
    _force_tag("loc_communication_wheel_display_name_thanks")
end

mod.tag_need_health = function()
    _force_tag("loc_communication_wheel_display_name_need_health")
end

mod.tag_enemy = function()
    _force_tag("loc_communication_wheel_display_name_enemy")
end

mod.tag_location = function()
    _force_tag("loc_communication_wheel_display_name_location")
end

mod.tag_attention = function()
    _force_tag("loc_communication_wheel_display_name_attention")
end

mod.tag_need_ammo = function()
    _force_tag("loc_communication_wheel_display_name_need_ammo")
end
