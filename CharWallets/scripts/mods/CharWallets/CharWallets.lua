local mod = get_mod("CharWallets")
local WalletSettings = require("scripts/settings/wallet_settings")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local ColorUtilities = require("scripts/utilities/ui/colors")

local ICON_PACKAGE = "packages/ui/views/end_player_view/end_player_view"
local BASE_WIDTH = 400
local BASE_OFFSET = 168
local DEFAULT_CURRENCY_ORDER = {
    "credits",
    "marks",
    "plasteel",
    "diamantine",
}
local currency_order = {}

local currency_icon_style = {
    size = { 24, 17 },
    offset = { BASE_OFFSET, 86, 10 }
}

local currency_text_style = table.clone(UIFontSettings.body_small)
currency_text_style.text_horizontal_alignment = "left"
currency_text_style.text_vertical_alignment = "bottom"
currency_text_style.horizontal_alignment = "left"
currency_text_style.vertical_alignment = "center"
currency_text_style.size = { 150, 20 }
currency_text_style.offset = { BASE_OFFSET, 40, 10 }
currency_text_style.text_color = Color.terminal_text_body_sub_header(255, true)
currency_text_style.default_color = Color.terminal_text_body_sub_header(255, true)
currency_text_style.hover_color = Color.terminal_text_header(255, true)

local contracts_text_style = table.clone(currency_text_style)
contracts_text_style.text_horizontal_alignment = "right"
contracts_text_style.offset = { 380, -8, 10 }

local _sort_custom_order = function(a, b)
    if a.idx == b.idx then
        return a.def_idx < b.def_idx
    end
    return a.idx < b.idx
end

local _build_currency_order = function()
    local order_builder = {}
    for default_idx, currency in pairs(DEFAULT_CURRENCY_ORDER) do
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

mod.on_setting_changed = function(setting_id)
    if setting_id:find("^order_") then
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

local _is_currency_displayed = function(c)
    return mod:get("show_" .. c)
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

    local adjusted_offset = BASE_OFFSET + mod:get("start_x")
    local adjusted_width = (BASE_WIDTH + mod:get("size_x")) / num_display

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
            offset = { adjusted_offset + offset + currency_icon_style.size[1], 40, 100 }
        }
    end

    style_overrides["contracts_text"] = {
        visible = _is_currency_displayed("contracts"),
        offset = { contracts_text_style.offset[1] + mod:get("contracts_x"), contracts_text_style.offset[2], contracts_text_style.offset[3] }
    }
    return style_overrides
end

local _insert_pass_if_absent = function(dest, source_pass)
    for _, dest_pass in pairs(dest) do
        if source_pass == dest_pass or source_pass.style_id == dest_pass.style_id or source_pass.value_id == dest_pass.value_id then
            return
        end
    end
    table.insert(dest, source_pass)
end

local _text_color_change = function(content, style)
    local math_max = math.max
    local hotspot = content.hotspot
    local default_color = hotspot.disabled and style.disabled_color or style.default_color
    local hover_color = style.hover_color
    local text_color = style.text_color
    local progress = math_max(math_max(hotspot.anim_focus_progress, hotspot.anim_select_progress), math_max(hotspot.anim_hover_progress, hotspot.anim_input_progress))

    ColorUtilities.color_lerp(default_color, hover_color, progress, text_color)
end

local _apply_extra_passes = function(onto)
    _ensure_order()
    for _, currency in pairs(currency_order) do
        _insert_pass_if_absent(onto, {
            value_id = currency .. "_icon",
            style_id = currency .. "_icon",
            pass_type = "texture",
            value = WalletSettings[currency].icon_texture_small,
            style = table.clone(currency_icon_style),
        })

        _insert_pass_if_absent(onto, {
            value_id = currency .. "_text",
            style_id = currency .. "_text",
            pass_type = "text",
            value = "---",
            style = table.clone(currency_text_style),
            change_function = _text_color_change
        })
    end

    _insert_pass_if_absent(onto, {
        value_id = "contracts_text",
        style_id = "contracts_text",
        pass_type = "text",
        value = _get_contracts_string("-", "-"),
        style = table.clone(contracts_text_style),
        change_function = _text_color_change
    })
end

mod:hook_require("scripts/ui/pass_templates/character_select_pass_templates", function(instance)
    _apply_extra_passes(instance.character_select)
end)

-- load the icons (h/t raindish)
local _load_package = function(p)
    if not Managers.package:is_loading(p) and not Managers.package:has_loaded(p) then
        Managers.package:load(p, mod.name, nil, true)
    end
end

function mod.on_all_mods_loaded()
    _load_package(ICON_PACKAGE)
end

mod:hook_safe("MainMenuView", "_set_player_profile_information", function(self, profile, widget)
    _ensure_order()
    
    local character_id = profile.character_id
    Managers.backend.interfaces.wallet:combined_wallets(character_id):next(function(wallets)
        for _, currency in pairs(currency_order) do
            local wallet = wallets:by_type(currency)
            if wallet then
                local label = currency .. "_text"
                if widget.content[label] then
                    widget.content[label] = wallet.balance.amount
                end
            end
        end
    end)

    Managers.backend.interfaces.contracts:get_current_contract(character_id):next(function(contract_data)
        local contract_tasks = contract_data.tasks
        local num_tasks_completed = 0
        local num_tasks = #contract_tasks
        for _, task in pairs(contract_tasks) do
            if task.fulfilled then
                num_tasks_completed = num_tasks_completed + 1
            end
        end

        local contracts_lbl = "contracts_text"
        if widget.content[contracts_lbl] then
            widget.content[contracts_lbl] = _get_contracts_string(num_tasks_completed, num_tasks, contract_data.fulfilled, contract_data.rewarded)
        end
    end)

    for style_id, style in pairs(_get_style_update()) do
        table.merge_recursive(widget.style[style_id], style)
    end
end)
