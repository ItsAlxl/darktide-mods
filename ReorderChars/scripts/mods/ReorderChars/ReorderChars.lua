local mod = get_mod("ReorderChars")

-- maps character_id->custom_idx
local custom_order = {}
local allow_reordering = Managers.ui and Managers.ui:has_active_view("main_menu_view")

local _save_order = function()
    for p_id, idx in pairs(custom_order) do
        mod:set(p_id, idx)
    end
end

mod.on_unload = function(quitting)
    _save_order()
end

mod:hook_safe("MainMenuView", "on_enter", function(...)
    allow_reordering = true
end)

mod:hook_safe("MainMenuView", "on_exit", function(...)
    allow_reordering = false
    _save_order()
end)

local _sort_profiles = function(a, b)
    local a_id = a.character_id
    local b_id = b.character_id

    if custom_order[a_id] and custom_order[b_id] then
        if custom_order[a_id] ~= custom_order[b_id] then
            return custom_order[a_id] < custom_order[b_id]
        end
    else
        if custom_order[a_id] then
            return true
        end
        if custom_order[b_id] then
            return false
        end
    end
    return a_id < b_id
end

mod:hook("MainMenuView", "_event_profiles_changed", function(func, self, profiles)
    for _, p in pairs(profiles) do
        local p_id = p.character_id
        local custom_idx = custom_order[p_id] or mod:get(p_id)

        if custom_idx then
            custom_order[p_id] = custom_idx
        end
    end

    table.sort(profiles, _sort_profiles)

    for idx, p in pairs(profiles) do
        local p_id = p.character_id
        custom_order[p_id] = idx
    end

    func(self, profiles)
end)

local _shift_idx = function(from, to)
    for c_id, idx in pairs(custom_order) do
        if idx == from then
            custom_order[c_id] = to
            return
        end
    end
end

local _move_current = function(up, id)
    if not allow_reordering then
        return
    end
    if not id and Managers.player and Managers.player:local_player(1) then
        id = Managers.player:local_player(1):character_id()
    end

    if not id then
        return
    end

    local base = custom_order[id]
    if not base then
        return
    end

    if up then
        if base > 1 then
            _shift_idx(base - 1, base)
            custom_order[id] = base - 1
        end
    else
        -- #custom_order won't work cuz it's not an array
        local num_profiles = 0
        for _ in pairs(custom_order) do
            num_profiles = num_profiles + 1
        end

        if base < num_profiles then
            _shift_idx(base + 1, base)
            custom_order[id] = base + 1
        end
    end

    Managers.event:trigger("event_main_menu_entered")
end

mod.move_current_up = function()
    _move_current(true)
end

mod.move_current_down = function()
    _move_current(false)
end
