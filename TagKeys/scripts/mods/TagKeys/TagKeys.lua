local mod = get_mod("TagKeys")
local Vo = require("scripts/utilities/vo")

local _cached_tagger = nil
local next_tag_t = nil

local _get_smart_tagger = function()
	if _cached_tagger then
		return _cached_tagger
	end
	if Managers.ui then
		local hud = Managers.ui:get_hud()
		_cached_tagger = hud and hud:element("HudElementSmartTagging")
		if _cached_tagger then
			mod:hook_safe(_cached_tagger, "destroy", function(...)
				_cached_tagger = nil
			end)
		end
		return _cached_tagger
	end
	return nil
end

local _find_wheel_option = function(smart_tagger, display_name)
	for _, entry in pairs(smart_tagger._entries) do
		if entry and entry.option and entry.option.display_name == display_name then
			return entry.option
		end
	end
	return nil
end

local _force_tag = function(display_name)
	local tagger = _get_smart_tagger()
	if not tagger then
		return
	end

	local now = Managers.time:time("main")
	if Managers.input:cursor_active() or (next_tag_t and now < next_tag_t) then
		return
	end

	local option = _find_wheel_option(tagger, display_name)
	if not option then
		return
	end

	-- taken from "scripts/ui/hud/elements/smart_tagging/hud_element_smart_tagging"
	local tag_type = option.tag_type

	if tag_type then
		local force_update_targets = true
		local raycast_data = tagger:_find_raycast_targets(force_update_targets)
		local hit_position = raycast_data.static_hit_position

		if hit_position then
			tagger:_trigger_smart_tag(tag_type, nil, Vector3Box.unbox(hit_position))
		end
	end

	local chat_message_data = option.chat_message_data

	if chat_message_data then
		local text = chat_message_data.text
		local channel_tag = chat_message_data.channel
		local channel, channel_handle = tagger:_get_chat_channel_by_tag(channel_tag)

		if channel then
			Managers.chat:send_loc_channel_message(channel_handle, text, nil)
		end
	end

	local voice_event_data = option.voice_event_data

	if voice_event_data then
		local parent = tagger._parent
		local player_unit = parent:player_unit()

		if player_unit then
			Vo.on_demand_vo_event(player_unit, voice_event_data.voice_tag_concept, voice_event_data.voice_tag_id)
		end
	end

	Managers.telemetry_reporters:reporter("com_wheel"):register_event(option.voice_event_data.voice_tag_id)
	next_tag_t = now + 0.25
end

for id, loc in pairs(mod.tags) do
	mod["_cb_" .. id] = function()
		_force_tag(loc)
	end
end
