local mod = get_mod("CharWallets")

mod.consts = {
    BASE_WIDTH = 400,
    BASE_OFFSET = 168,
    DEFAULT_CURRENCY_ORDER = {
        "credits",
        "marks",
        "plasteel",
        "diamantine",
    },
    ICON_PACKAGE = "packages/ui/views/end_player_view/end_player_view",
    ICON_SIZE = { 24, 17 },
    CONTRACTS_TEXT_OFFSET = { 380, -8, 10 }
}

mod:io_dofile("CharWallets/scripts/mods/CharWallets/PassTemplates")
local PlayerProgressionUnlocks = require("scripts/settings/player/player_progression_unlocks")

local MAIN_MENU_VIEW = "main_menu_view"
local BILLION = 10 ^ 9
local MILLION = 10 ^ 6
local THOUSAND = 10 ^ 3

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
    for default_idx, currency in pairs(mod.consts.DEFAULT_CURRENCY_ORDER) do
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

local _is_currency_displayed = function(c)
    return mod:is_enabled() and mod:get("show_" .. c)
end

local _get_style_update = function()
    local num_display = 0
    local currency_to_idx = {}

    _ensure_order()
    for _, currency in pairs(currency_order) do
        if _is_currency_displayed(currency) then
            num_display = num_display + 1
            currency_to_idx[currency] = num_display
        else
            currency_to_idx[currency] = -1
        end
    end

    if num_display == 0 then
        num_display = 1 -- prevent division by zero
    end

    local adjusted_offset = mod.consts.BASE_OFFSET + mod:get("start_x")
    local adjusted_width = (mod.consts.BASE_WIDTH + mod:get("size_x")) / num_display

    local style_overrides = {}
    for _, currency in pairs(currency_order) do
        local idx = currency_to_idx[currency]
        local offset = adjusted_width * (idx - 1)
        style_overrides[currency .. "_icon"] = {
            visible = idx > 0,
            offset = { adjusted_offset + offset, 86, 100 }
        }
        style_overrides[currency .. "_text"] = {
            visible = idx > 0,
            offset = { adjusted_offset + offset + mod.consts.ICON_SIZE[1], 40, 100 }
        }
    end

    style_overrides["contracts_text"] = {
        visible = _is_currency_displayed("contracts"),
        offset = { mod.consts.CONTRACTS_TEXT_OFFSET[1] + mod:get("contracts_x"), mod.consts.CONTRACTS_TEXT_OFFSET[2], mod.consts.CONTRACTS_TEXT_OFFSET[3] }
    }
    return style_overrides
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

mod.refresh_profile = function(profile)
    if not profile then
        return
    end
    local widget = profile_to_widget[profile]
    if not widget then
        return
    end

    local character_id = profile.character_id
    _get_character_wallet(character_id):next(function(wallets)
        for _, currency in pairs(currency_order) do
            local wallet = wallets:by_type(currency)
            if wallet then
                local label = currency .. "_text"
                if widget.content[label] then
                    widget.content[label] = _get_currency_string(wallet.balance.amount)
                end
            end
        end
    end)

    local contracts_lbl = "contracts_text"
    if profile.current_level >= PlayerProgressionUnlocks.contracts then
        Managers.backend.interfaces.contracts:get_current_contract(character_id):next(function(contract_data)
            local contract_tasks = contract_data.tasks
            local num_tasks_completed = 0
            local num_tasks = #contract_tasks
            for _, task in pairs(contract_tasks) do
                if task.fulfilled then
                    num_tasks_completed = num_tasks_completed + 1
                end
            end

            if widget.content[contracts_lbl] then
                widget.content[contracts_lbl] = _get_contracts_string(num_tasks_completed, num_tasks, contract_data.fulfilled, contract_data.rewarded)
            end
        end)
    else
        widget.content[contracts_lbl] = ""
    end
end

mod.refresh_all_profiles = function()
    for profile, _ in pairs(profile_to_widget) do
        mod.refresh_profile(profile)
    end
end

mod.refresh_all_style = function()
    for _, widget in pairs(profile_to_widget) do
        for style_id, style in pairs(_get_style_update()) do
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
    if Managers.ui and Managers.ui:has_active_view(MAIN_MENU_VIEW) and view_name ~= MAIN_MENU_VIEW and view_name ~= "system_view" then
        mod.refresh_all()
    end
end)

mod.on_disabled = function ()
    mod.refresh_all_style()
end

mod.on_enabled = function ()
    mod.refresh_all()
end
