local mod = get_mod("CharWallets")

local ColorUtilities = require("scripts/utilities/ui/colors")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local WalletSettings = require("scripts/settings/wallet_settings")

local currency_icon_style = {
    size = mod.consts.ICON_SIZE,
    offset = { mod.consts.BASE_OFFSET, 86, 10 },
    visible = false
}

local currency_text_style = table.clone(UIFontSettings.body_small)
currency_text_style.text_horizontal_alignment = "left"
currency_text_style.text_vertical_alignment = "bottom"
currency_text_style.horizontal_alignment = "left"
currency_text_style.vertical_alignment = "center"
currency_text_style.size = { 150, 20 }
currency_text_style.offset = { mod.consts.BASE_OFFSET, 40, 10 }
currency_text_style.text_color = Color.terminal_text_body_sub_header(255, true)
currency_text_style.default_color = Color.terminal_text_body_sub_header(255, true)
currency_text_style.hover_color = Color.terminal_text_header(255, true)
currency_text_style.visible = false

local contracts_text_style = table.clone(currency_text_style)
contracts_text_style.text_horizontal_alignment = "right"
contracts_text_style.offset = mod.consts.CONTRACTS_TEXT_OFFSET

local _text_color_change = function(content, style)
    local math_max = math.max
    local hotspot = content.hotspot
    local default_color = hotspot.disabled and style.disabled_color or style.default_color
    local hover_color = style.hover_color
    local text_color = style.text_color
    local progress = math_max(math_max(hotspot.anim_focus_progress, hotspot.anim_select_progress), math_max(hotspot.anim_hover_progress, hotspot.anim_input_progress))

    ColorUtilities.color_lerp(default_color, hover_color, progress, text_color)
end

mod:hook_require("scripts/ui/pass_templates/character_select_pass_templates", function(CharacterSelectPassTemplates)
    for _, currency in pairs(mod.consts.DEFAULT_CURRENCY_ORDER) do
        table.insert(CharacterSelectPassTemplates.character_select, {
            value_id = currency .. "_icon",
            style_id = currency .. "_icon",
            pass_type = "texture",
            value = WalletSettings[currency].icon_texture_small,
            style = currency_icon_style,
        })
        table.insert(CharacterSelectPassTemplates.character_select, {
            value_id = currency .. "_text",
            style_id = currency .. "_text",
            pass_type = "text",
            value = "---",
            style = currency_text_style,
            change_function = _text_color_change
        })
    end

    table.insert(CharacterSelectPassTemplates.character_select, {
        value_id = "contracts_text",
        style_id = "contracts_text",
        pass_type = "text",
        value = "---",
        style = contracts_text_style,
        change_function = _text_color_change
    })
end)

-- load the icons (h/t raindish)
local _load_package = function(p)
    if not Managers.package:is_loading(p) and not Managers.package:has_loaded(p) then
        Managers.package:load(p, mod.name, nil, true)
    end
end

function mod.on_all_mods_loaded()
    _load_package(mod.consts.ICON_PACKAGE)
end