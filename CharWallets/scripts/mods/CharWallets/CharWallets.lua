local mod = get_mod("CharWallets")

local PlayerProgressionUnlocks = require("scripts/settings/player/player_progression_unlocks")
local Style = mod:io_dofile("CharWallets/scripts/mods/CharWallets/PassTemplates")

local MAIN_MENU_BG_VIEW = "main_menu_background_view"
local BILLION = 10 ^ 9
local MILLION = 10 ^ 6
local THOUSAND = 10 ^ 3
local IGNORE_VIEW_UPDATES = {
    MAIN_MENU_BG_VIEW,
    "main_menu_view",
    "system_view",
    "loading_view",
    "title_view",
}

local currency_order = {}
local profile_to_widget = mod:persistent_table("profile_to_widget")

local _sort_custom_order = function(a, b)
    if a.idx == b.idx then
        return a.def_idx < b.def_idx
    end
    return a.idx < b.idx
end

local _build_currency_order = function()
    local order_builder = {}
    for default_idx, currency in pairs(mod.DEFAULT_CURRENCY_ORDER) do
        table.insert(order_builder, {
            currency = currency,
            idx = mod:get("order_" .. currency),
            def_idx = default_idx
        })
    end
    table.sort(order_builder, _sort_custom_order)

    table.clear(currency_order)
    for _, sorter in pairs(order_builder) do
        table.insert(currency_order, sorter.currency)
    end
end

local _ensure_order = function()
    if #currency_order == 0 then
        _build_currency_order()
    end
end

local _get_contracts_string = function(num_completed, num_tasks, finished, bonus_rewarded)
    local s = num_completed .. "/" .. num_tasks .. ""
    if finished then
        if bonus_rewarded then
            s = s .. " []"
        else
            s = s .. " [!]"
        end
    end
    return s
end

local _get_digit_count = function(num)
    return math.floor(math.log(num, 10) + 1)
end

local _get_currency_string = function(num)
    if mod:get("limit_digits") then
        local suffix = ""
        if num >= BILLION then
            suffix = mod:localize("shortened_billion")
            num = num / BILLION
        elseif num >= MILLION then
            suffix = mod:localize("shortened_million")
            num = num / MILLION
        elseif num >= THOUSAND then
            suffix = mod:localize("shortened_thousand")
            num = num / THOUSAND
        end
        local decimal_places = 3 - _get_digit_count(num)
        if suffix == "" or decimal_places < 0 then
            decimal_places = 0
        end
        return string.format("%." .. decimal_places .. "f%s", num, suffix)
    end
    return num
end

mod.on_setting_changed = function(id)
    if string.find(id, "^order_") then
        _build_currency_order()
        mod.refresh_all_style()
    elseif string.find(id, "_x$") then
        mod.refresh_all_style()
    end
end

local _get_character_wallet = function(character_id)
    local wallets_promise = nil
    local store_service = Managers.data_service.store

    if store_service._wallets_cache then
        wallets_promise = store_service._wallets_cache:get_data(character_id, function()
            return store_service._backend_interface.wallet:character_wallets(character_id)
        end)
    else
        wallets_promise = store_service._backend_interface.wallet:character_wallets(character_id)
    end

    return wallets_promise:next(function(wallets)
        return store_service:_decorate_wallets(wallets)
    end)
end

local _in_main_menu = function()
    return Managers.ui and Managers.ui:has_active_view(MAIN_MENU_BG_VIEW)
end

local _get_character_contracts = function(character_id)
    return Managers.data_service.contracts._backend_interface.contracts:get_current_contract(character_id)
end

mod.refresh_profile = function(profile)
    if not profile or not _in_main_menu() then
        return
    end
    local widget = profile_to_widget[profile]
    if not widget or not widget.content then
        return
    end

    local character_id = profile.character_id
    _get_character_wallet(character_id):next(function(wallets)
        for _, currency in pairs(currency_order) do
            widget.content[currency .. "_text"] = _get_currency_string(wallets:by_type(currency).balance.amount)
        end
    end)

    local contracts_lbl = "contracts_text"
    if profile.current_level >= PlayerProgressionUnlocks.contracts then
        local contracts = _get_character_contracts(character_id)
        if contracts then
            _get_character_contracts(character_id):next(function(contract_data)
                local contract_tasks = contract_data.tasks
                local num_tasks_completed = 0
                local num_tasks = #contract_tasks
                for _, task in pairs(contract_tasks) do
                    if task.fulfilled then
                        num_tasks_completed = num_tasks_completed + 1
                    end
                end
                widget.content[contracts_lbl] = _get_contracts_string(num_tasks_completed, num_tasks, contract_data.fulfilled, contract_data.rewarded)
            end)
        else
            widget.content[contracts_lbl] = "---"
        end
    else
        widget.content[contracts_lbl] = "---"
    end
end

mod.refresh_all_profiles = function()
    if not _in_main_menu() then
        return
    end
    for profile, _ in pairs(profile_to_widget) do
        mod.refresh_profile(profile)
    end
end

mod.refresh_all_style = function()
    if not _in_main_menu() then
        return
    end
    _ensure_order()
    for _, widget in pairs(profile_to_widget) do
        for style_id, style in pairs(Style.get_style_update(currency_order)) do
            table.merge_recursive(widget.style[style_id], style)
        end
    end
end

mod.refresh_all = function()
    mod.refresh_all_style()
    mod.refresh_all_profiles()
end

mod:hook(CLASS.MainMenuView, "_sync_character_slots", function(func, ...)
    table.clear(profile_to_widget)
    _build_currency_order()
    func(...)
    mod.refresh_all_style()
end)

mod:hook_safe(CLASS.MainMenuView, "_set_player_profile_information", function(self, profile, widget)
    profile_to_widget[profile] = widget
    mod.refresh_profile(profile)
end)

mod:hook_safe(CLASS.UIViewHandler, "close_view", function(self, view_name, ...)
    if _in_main_menu() and not table.contains(IGNORE_VIEW_UPDATES, view_name) then
        mod.refresh_all()
    end
end)

mod.on_disabled = function()
    mod.refresh_all_style()
end

mod.on_enabled = function()
    mod.refresh_all()
end
