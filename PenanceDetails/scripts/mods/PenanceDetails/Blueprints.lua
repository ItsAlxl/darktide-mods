local mod = get_mod("PenanceDetails")
local ColorUtilities = require("scripts/utilities/ui/colors")
local ViewBlueprints = require("scripts/ui/views/achievements_view/achievements_view_blueprints")
local ViewStyles = require("scripts/ui/views/achievements_view/achievements_view_styles")

local _foldout_visibility_function = function(content, style)
    return content.unfolded
end

local _common_icon_hover_change_function = function(content, style)
    local hotspot = content.hotspot
    local focus_progress = hotspot.anim_focus_progress
    local hover_progress = hotspot.anim_hover_progress
    local target_color, icon_target_color = nil

    if hover_progress < focus_progress then
        hover_progress = focus_progress
        target_color = style.selected_color
        icon_target_color = style.icon_selected_color
    else
        target_color = style.hover_color
        icon_target_color = style.icon_hover_color
    end

    local color_lerp = ColorUtilities.color_lerp
    if target_color then
        color_lerp(style.default_color, target_color, hover_progress, style.color)
    end

    if icon_target_color then
        local material_values = style.material_values

        color_lerp(style.icon_default_color, icon_target_color, hover_progress, material_values.icon_color)
    end
end

local _get_prog_detail_icon_id = function(idx)
    return "prog_detail_icon_" .. idx
end

local _get_prog_detail_label_id = function(idx)
    return "prog_detail_label_" .. idx
end

local _prepend_table = function(destination, source)
    for i = #source, 1, -1 do
        table.insert(destination, 1, source[i])
    end
end

local _prog_details_pass_template_init = function(widget_content, widget_style, config, folded_height)
    local prog_details = config.prog_details
    local sub_achievement_margin = ViewStyles.blueprints.pass_template.meta_sub_achievement_margins[2]
    local sub_achievement_offset_y = folded_height

    for i = 1, #prog_details do
        local prog_detail = prog_details[i]
        local prog_detail_label_name = _get_prog_detail_label_id(i)

        local is_flag = type(prog_detail.progress) == "boolean"
        if is_flag then
            widget_content[prog_detail_label_name] = prog_detail.display_name
        else
            widget_content[prog_detail_label_name] = string.format("%s: %s", prog_detail.display_name, prog_detail.progress)
        end

        local sub_label_style = widget_style[prog_detail_label_name]
        sub_label_style.offset[2] = sub_label_style.offset[2] + sub_achievement_offset_y

        local icon_style = widget_style[_get_prog_detail_icon_id(i)]
        local icon_offset = icon_style.offset
        icon_offset[2] = icon_offset[2] + sub_achievement_offset_y
        local icon_material_values = icon_style.material_values

        local completed = false
        if is_flag then
            completed = prog_detail.progress
            sub_label_style.offset[3] = sub_label_style.completed_layer
            if completed then
                sub_label_style.text_color = sub_label_style.completed_color
            end
        else
            completed = config.completed
            icon_style.visible = false
            sub_label_style.text_color = Color.terminal_text_body(255, true)
        end

        if completed then
            icon_style.icon_default_color = icon_style.icon_completed_color
            icon_style.icon_hover_color = icon_style.icon_completed_hover_color
            icon_style.icon_selected_color = icon_style.icon_completed_selected_color
            icon_material_values.frame = icon_style.completed_frame
            sub_label_style.offset[3] = sub_label_style.completed_layer
        end
        sub_achievement_offset_y = icon_offset[2] + icon_style.size[2]
    end

    return sub_achievement_offset_y + sub_achievement_margin
end

mod:hook(ViewBlueprints.foldout_achievement, "pass_template_function", function(func, parent, config)
    local pass_template = func(parent, config)

    local prog_details = config.prog_details
    if prog_details then
        local prog_detail_passes = {}
        for i, _ in pairs(prog_details) do
            local prog_detail_icon_name = _get_prog_detail_icon_id(i)
            local prog_detail_label_name = _get_prog_detail_label_id(i)

            table.append(prog_detail_passes, {
                {
                    pass_type = "texture",
                    value = "content/ui/materials/icons/achievements/achievement_icon_container",
                    value_id = prog_detail_icon_name,
                    style_id = prog_detail_icon_name,
                    change_function = _common_icon_hover_change_function,
                    visibility_function = _foldout_visibility_function
                },
                {
                    pass_type = "text",
                    value_id = prog_detail_label_name,
                    style_id = prog_detail_label_name,
                    visibility_function = _foldout_visibility_function
                }
            })
        end
        _prepend_table(pass_template, prog_detail_passes)
    end

    return pass_template
end)

mod:hook(ViewBlueprints.foldout_achievement, "style_function", function(func, parent, config)
    local style = func(parent, config)

    local prog_details = config.prog_details
    if prog_details then
        local meta_sub_style = ViewStyles.blueprints.pass_template.meta_sub_achievements
        for i = 1, #prog_details do
            style[_get_prog_detail_icon_id(i)] = meta_sub_style.sub_icon
            style[_get_prog_detail_label_id(i)] = meta_sub_style.sub_label
        end
    end

    return style
end)

mod:hook(ViewBlueprints.foldout_achievement, "init", function(func, parent, widget, config, callback_name, secondary_callback_name, ui_renderer)
    func(parent, widget, config, callback_name, secondary_callback_name, ui_renderer)

    if config.prog_details then
        local widget_content = widget.content
        local widget_style = widget.style
        widget_content.unfolded_height = _prog_details_pass_template_init(widget_content, widget_style, config, widget_content.unfolded_height)
    end
end)
