local mod = get_mod("RememberTheRealWorld")

local Promise = require("scripts/foundation/utilities/promise")
local session = mod:persistent_table("session")

local track_notification = function(id)
	session.notification = id

	local duration = mod:get("reminder_duration")
	if duration > 0 then
		local p = Promise.delay(duration)
		session.duration_promise = p
		p:next(mod.destroy_reminder)
	end
end

local time_since = function(finish, start)
	local diff_mins = math.ceil((finish - (start or 0)) / 60)
	local h = math.floor(diff_mins / 60)
	return h, diff_mins - (60 * h), diff_mins
end

mod.try_create_reminder = function()
	local since_launch = Application.time_since_launch()
	local since_previous = session.previous_reminder
	local h_last, m_last, diff_mins = time_since(since_launch, since_previous)
	if diff_mins >= mod:get("reminder_interval") then
		local texts = { "", "", mod:localize("time_for_break") }
		if since_previous then
			local h_launch, m_launch = time_since(since_launch)
			texts[1] = mod:localize("first_reminder_message", h_launch, m_launch)
			texts[2] = mod:localize("later_reminder_message", h_last, m_last)
		else
			texts[1] = mod:localize("first_reminder_message", h_last, m_last)
		end
		session.previous_reminder = since_launch

		mod.destroy_reminder()
		Managers.event:trigger(
			"event_add_notification_message",
			"matchmaking",
			{ texts = texts },
			track_notification
		)
	end
end

mod.destroy_reminder = function()
	if session.duration_promise then
		session.duration_promise:cancel()
	end
	if session.notification then
		Managers.event:trigger("event_remove_notification", session.notification)
		session.notification = nil
	end
end

mod:hook(CLASS.GameModeManager, "init", function(func, self, game_mode_context, game_mode_name, ...)
	mod.destroy_reminder()

	if game_mode_name == "hub" then
		if session.has_hubbed then
			mod.try_create_reminder()
		else
			session.has_hubbed = true
		end
	end
	func(self, game_mode_context, game_mode_name, ...)
end)
