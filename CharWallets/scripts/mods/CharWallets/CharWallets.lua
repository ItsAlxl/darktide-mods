local mod = get_mod("CharWallets")
local WalletSettings = require("scripts/settings/wallet_settings")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local ColorUtilities = require("scripts/utilities/ui/colors")

local BASE_WIDTH = 400
local BASE_OFFSET = 168
local CURRENCY_ORDER = {
    "credits",
    "marks",
    "plasteel",
    "diamantine",
}

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

local _is_currency_displayed = function(c)
    return mod:get("show_" .. c)
end

local _get_style_update = function()
    local num_display = 0
    local currency_to_idx = {}

    for _, currency in pairs(CURRENCY_ORDER) do
        if mod:get("show_" .. currency) then
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
    for _, currency in pairs(CURRENCY_ORDER) do
        local offset = adjusted_width * (currency_to_idx[currency] - 1)
        style_overrides[currency .. "_icon"] = {
            visible = _is_currency_displayed(currency),
            offset = { adjusted_offset + offset, 86, 100 }
        }
        style_overrides[currency .. "_text"] = {
            visible = _is_currency_displayed(currency),
            offset = { adjusted_offset + offset + currency_icon_style.size[1], 40, 100 }
        }
    end
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

local _apply_extra_passes = function(onto)
    for _, currency in pairs(CURRENCY_ORDER) do
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
            change_function = function(content, style)
                local math_max = math.max
                local hotspot = content.hotspot
                local default_color = hotspot.disabled and style.disabled_color or style.default_color
                local hover_color = style.hover_color
                local text_color = style.text_color
                local progress = math_max(math_max(hotspot.anim_focus_progress, hotspot.anim_select_progress), math_max(hotspot.anim_hover_progress, hotspot.anim_input_progress))

                ColorUtilities.color_lerp(default_color, hover_color, progress, text_color)
            end
        })
    end
end

mod:hook_require("scripts/ui/pass_templates/character_select_pass_templates", function(instance)
    _apply_extra_passes(instance.character_select)
end)

-- load in the icons (h/t raindish)
function mod.on_all_mods_loaded()
    mod:load_package("packages/ui/views/end_player_view/end_player_view")
end

mod:hook("MainMenuView", "_set_player_profile_information", function(func, self, profile, widget)
    func(self, profile, widget)

    Managers.backend.interfaces.wallet:combined_wallets(profile.character_id):next(function(wallets)
        for _, currency in pairs(CURRENCY_ORDER) do
            local wallet = wallets:by_type(currency)
            if wallet then
                local label = currency .. "_text"
                if widget.content[label] then
                    widget.content[label] = wallet.balance.amount
                end
            end
        end
        for style_id, style in pairs(_get_style_update()) do
            table.merge_recursive(widget.style[style_id], style)
        end
    end)
end)
