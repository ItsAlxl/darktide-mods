local mod = get_mod("ToggleInteract")
local InputHandlerSettings = require("scripts/managers/player/player_game_states/input_handler_settings")

local RELEASE_SUFFIX = "_release$"
local ephemeral_actions = InputHandlerSettings.ephemeral_actions

local prev_interacting = false
local keep_interacting = false

local options = {
    interact_cancel = mod:get("interact_cancel"),
    ephemeral_cancel = mod:get("ephemeral_cancel"),
    replace_tooltip = mod:get("replace_tooltip"),
}

local requested_ephemeral = nil

mod.on_setting_changed = function(id)
    options[id] = mod:get(id)
end

local _does_action_cancel = function(action_name)
    if (options.ephemeral_cancel or options.interact_cancel) and table.contains(ephemeral_actions, action_name) then
        if action_name == "interact_pressed" then
            return options.interact_cancel
        end
        if options.ephemeral_cancel and not string.find(action_name, RELEASE_SUFFIX) then
            requested_ephemeral = action_name
            return true
        end
    end
    return false
end

local _input_action_hook = function(func, self, action_name)
    local val = func(self, action_name)
    if action_name == requested_ephemeral then
        requested_ephemeral = nil
        return true
    end
    if keep_interacting then
        if val and _does_action_cancel(action_name) then
            keep_interacting = false
        end
        if action_name == "interact_hold" then
            return true
        end
    end
    return val
end
mod:hook(CLASS.InputService, "_get", _input_action_hook)
mod:hook(CLASS.InputService, "_get_simulate", _input_action_hook)

mod:hook_safe(CLASS.InteractorExtension, "fixed_update", function(self, ...)
    local is_interacting = self:is_interacting()
    if is_interacting ~= prev_interacting then
        keep_interacting = is_interacting
    end
    prev_interacting = is_interacting
end)

mod:hook(CLASS.LocalizationManager, "localize", function(func, self, key, ...)
    if options.replace_tooltip and key == "loc_interaction_input_type_hold" then
        key = "loc_interaction_input_type"
    end
    return func(self, key, ...)
end)
