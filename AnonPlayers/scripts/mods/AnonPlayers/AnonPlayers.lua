local mod = get_mod("AnonPlayers")
local Personalities = require("scripts/settings/character/personalities")
local ProfileUtils = require("scripts/utilities/profile_utils")

local _is_my_profile = function(profile)
	return profile == Managers.player:local_player(1)._profile
end

local get_personality = function(personality_key, voice_fallback)
	local personality = Personalities[personality_key]
	if personality then
		return personality
	end

	-- FS changed the keys, but (at the time of writing) there is no compat for old keys
	for _, p in pairs(Personalities) do
		if p.character_voice == voice_fallback then
			return p
		end
	end

	return nil
end

mod.anonymize = function(profile, real_name, is_account)
	local no_profile = not (profile and profile.character_id and profile.lore and profile.lore.backstory and profile.lore.backstory.personality)
	local is_me = Managers.ui and Managers.ui:view_active("main_menu_view") or _is_my_profile(profile)

	local anon_mode = is_me
		and (is_account and mod:get("anon_my_account") or mod:get("anon_me"))
		or (is_account and mod:get("anon_other_accounts") or mod:get("anon_others"))
		or 1

	if anon_mode == 0 then
		return real_name
	end

	if no_profile or anon_mode == 1 then
		return mod:localize(is_me and "mask_me" or "mask_other")
	elseif anon_mode == 2 then
		local personality_key = table.nested_get(profile, "lore", "backstory", "personality")
		local personality = personality_key and get_personality(personality_key, profile.selected_voice)
		if not personality then
			mod:warning("can't find personality: %s", personality_key)
			return mod:localize(is_me and "mask_me" or "mask_other")
		end
		return Localize(personality.display_name)
	elseif anon_mode >= 3 then
		local id = string.sub(profile.character_id, 1, 5)

		if anon_mode == 3 then
			return id
		end

		local pool = profile.gender == "male" and ProfileUtils.character_names.male_names_1 or
			ProfileUtils.character_names.female_names_1
		return pool[1 + (math.abs(tonumber(id, 16) or 1) % #pool)]
	end
	return real_name
end

-- all names (including mine) in Social & chat, during end-of-match
mod:hook(CLASS.PlayerInfo, "character_name", function(func, self)
	return mod.anonymize(self:profile(), func(self))
end)

-- account names in Social, during end-of-match
mod:hook_origin(CLASS.PlayerInfo, "user_display_name", function(self, use_stale)
	local name = self._user_display_name
	if use_stale and name then
		return name
	end
	local presence = self:_get_presence()
	local platform_social = self._platform_social
	name = presence and presence:platform_persona_name_or_account_name() or platform_social and platform_social:name() or
		self._account_name or "N/A"

	local profile = self:profile()
	name = mod.anonymize(profile, name, true)

	local is_me = _is_my_profile(profile)
	if is_me and mod:get("show_my_platform") or (not is_me and mod:get("show_other_platform")) then
		local platform_icon = self:platform_icon()
		if platform_icon then
			name = string.format("%s %s", platform_icon, name)
		end
	end

	self._user_display_name = name
	return name
end)

-- over their heads in hub, used all over throughout a match, INCLUDING BOTS
mod:hook(CLASS.RemotePlayer, "name", function(func, self)
	return mod.anonymize(self._profile, func(self))
end)

-- my name in lower-left HUD
mod:hook(CLASS.HumanPlayer, "name", function(func, self)
	return mod.anonymize(self._profile, func(self))
end)

mod:hook(CLASS.BotPlayer, "name", function(func, self)
	return mod.anonymize(self._profile, func(self))
end)

mod:hook(CLASS.RemotePlayer, "character_name", function(func, self)
	return mod.anonymize(self._profile, func(self))
end)

-- when inviting, joining parties
mod:hook(CLASS.PresenceEntryMyself, "character_name", function(func, self)
	return mod.anonymize(self:character_profile(), func(self))
end)

mod:hook(CLASS.PresenceEntryImmaterium, "character_name", function(func, self)
	return mod.anonymize(self:character_profile(), func(self))
end)

-- in pre-mission lobby & character select
mod:hook_require("scripts/utilities/profile_utils", function(instance)
	mod:hook(instance, "character_name", function(func, profile)
		return mod.anonymize(profile, func(profile))
	end)
end)
