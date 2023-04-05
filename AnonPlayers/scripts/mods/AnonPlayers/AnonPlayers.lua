local mod = get_mod("AnonPlayers")
local Personalities = require("scripts/settings/character/personalities")
local ProfileUtils = require("scripts/utilities/profile_utils")

local anon_rules = {
    anon_me = mod:get("anon_me"),
    anon_my_account = mod:get("anon_my_account"),
    anon_others = mod:get("anon_others"),
    anon_other_accounts = mod:get("anon_other_accounts"),
}

local in_char_select = Managers.ui and Managers.ui:has_active_view("main_menu_view")

mod:hook_safe("MainMenuView", "on_enter", function(...)
    in_char_select = true
end)

mod:hook_safe("MainMenuView", "on_exit", function(...)
    in_char_select = false
end)

mod.on_setting_changed = function(id)
    if anon_rules[id] ~= nil then
        anon_rules[id] = mod:get(id)
    end
end

local _anonymize = function(profile, real_name, is_account)
    local anon_mode = -1
    local no_profile = false
    if not profile then
        no_profile = true
    end

    local is_me = false
    if no_profile or not profile.character_id or string.find(profile.character_id, "^bot_") then
        -- it's a bot, no need to anonymize
        anon_mode = 0
    else
        if in_char_select or profile == Managers.player:local_player(1)._profile then
            is_me = true
        end

        if is_me then
            if is_account then
                anon_mode = anon_rules.anon_my_account
            else
                anon_mode = anon_rules.anon_me
            end
        else
            if is_account then
                anon_mode = anon_rules.anon_other_accounts
            else
                anon_mode = anon_rules.anon_others
            end
        end
    end

    if not anon_mode or anon_mode < 0 then
        return ""
    end

    if no_profile or anon_mode == 1 then
        if is_me then
            return mod:localize("mask_me")
        else
            return mod:localize("mask_other")
        end
    elseif anon_mode == 2 then
        return Localize(Personalities[profile.lore.backstory.personality].display_name)
    elseif anon_mode >= 3 then
        local id = string.sub(profile.character_id, 1, 5)

        if anon_mode == 3 then
            return id
        end

        local pool = ProfileUtils.character_names.female_names_1
        if profile.gender == "male" then
            pool = ProfileUtils.character_names.male_names_1
        end

        local idx = tonumber(id, 16)
        if idx == nil or idx < 1 then
            mod:warning("%s -> %s results in nil", profile.character_id, id)
            idx = 1
        end

        return pool[1 + (idx % #pool)]
    end

    return real_name
end

-- all names (including mine) in Social & chat, during end-of-match
mod:hook(CLASS.PlayerInfo, "character_name", function(func, self)
    return _anonymize(self:profile(), func(self))
end)

-- all account names (including mine) in Social, during end-of-match
mod:hook(CLASS.PlayerInfo, "user_display_name", function(func, self)
    return _anonymize(self:profile(), func(self), true)
end)

-- over their heads in hub, used all over throughout a match, INCLUDING BOTS
mod:hook(CLASS.RemotePlayer, "name", function(func, self)
    return _anonymize(self._profile, func(self))
end)

-- my name in lower-left HUD
mod:hook(CLASS.HumanPlayer, "name", function(func, self)
    return _anonymize(self._profile, func(self))
end)

mod:hook(CLASS.BotPlayer, "name", function(func, self)
    return _anonymize(self._profile, func(self))
end)

mod:hook(CLASS.RemotePlayer, "character_name", function(func, self)
    return _anonymize(self._profile, func(self))
end)

-- when inviting, joining parties
mod:hook(CLASS.PresenceEntryImmaterium, "character_name", function(func, self)
    return _anonymize(self:character_profile(), func(self))
end)

-- when inviting, joining parties
mod:hook(CLASS.PresenceEntryMyself, "character_name", function(func, self)
    return _anonymize(self:character_profile(), func(self))
end)

-- in pre-mission lobby & character select
mod:hook_require("scripts/utilities/profile_utils", function(instance)
    mod:hook(instance, "character_name", function(func, profile)
        return _anonymize(profile, func(profile))
    end)
end)
