local mod = get_mod("PenanceDetails")
local AchievementStats = require("scripts/managers/stats/groups/achievement_stats")
local AchievementUIHelper = require("scripts/managers/achievements/utility/achievement_ui_helper")
local AchievementUITypes = require("scripts/settings/achievements/achievement_ui_types")

mod:io_dofile("PenanceDetails/scripts/mods/PenanceDetails/Blueprints")

local ACHIEVEMENT_GRID = 2
local IGNORE_DETAILS = {
    ogryn_2_lunge_distance_last_x_seconds = true,
    zealot_2_kills_of_shocked_enemies_last_15 = true,
    zealot_2_stagger_sniper_with_grenade_distance = true,
    veteran_2_kills_with_last_round_in_mag = true,
    weakspot_hit_during_volley_fire_alternate_fire = true,
    dodges_in_a_row = true,
    head_shot_kill_in_a_row = true,
    different_players_rescued = true,
}

local _get_trigger_info = function(id)
    local trigger_info = {}
    local achievement = Managers.achievements:achievement_definition_from_id(id)
    if achievement then
        local triggers = achievement._trigger_component._triggers
        if triggers then
            for _, trigger_id in pairs(triggers) do
                trigger_info[trigger_id] = {}
                local trigger = AchievementStats.definitions[trigger_id]
                if trigger then
                    for _, flag_id in pairs(trigger._triggered_by) do
                        table.insert(trigger_info[trigger_id], flag_id)
                    end
                end
                table.sort(trigger_info[trigger_id])
            end
        end
    end
    table.sort(trigger_info)
    return trigger_info
end

local _localize_detail_name = function(detail_name)
    local breed_name = string.match(detail_name, "_%w+_%w-_-killed_(%S+)")
    if breed_name then
        return Localize("loc_breed_display_name_" .. breed_name)
    end
    local objective_type = string.match(detail_name, "_mission_%w-_-%d-_%d_objectives_(%d)_flag")
    if objective_type then
        return Localize(string.format("loc_mission_type_%02d_name", objective_type))
    end
    return mod:localize(detail_name)
end

local _get_stat = function(achievement_data, stat_id)
    if not achievement_data then
        return nil
    end

    local stat_definition = AchievementStats.definitions[stat_id]
    if stat_definition then
        local raw_val = stat_definition:get_raw(achievement_data.stats)
        if string.find(stat_id, "_flag$") then
            if raw_val then
                return true
            end
            return false
        end
        return raw_val or 0
    end
    return nil
end

local _should_ignore_detail = function(detail_name)
    return IGNORE_DETAILS[detail_name] or string.find(detail_name, "^_echo_") or string.find(detail_name, "last_%d+_sec")
end

local _make_prog_details = function(prog_details, achievement_data, displayed_progress)
    local final_details = {}
    for _, details in pairs(prog_details) do
        if #details == 1 then
            local progress = _get_stat(achievement_data, details[1])
            if progress == nil or progress == displayed_progress then
                break
            end
        end

        for _, detail in pairs(details) do
            if not _should_ignore_detail(detail) then
                table.insert(final_details, {
                    display_name = _localize_detail_name(detail),
                    progress = _get_stat(achievement_data, detail)
                })
            end
        end
    end
    return final_details
end

local _get_prog_details = function(achievement_id, achievement_data, displayed_progress)
    return _make_prog_details(_get_trigger_info(achievement_id), achievement_data, displayed_progress)
end

local _completion_time_sort_function = function(a, b)
    local a_completed_time = a.completed_time
    local b_completed_time = b.completed_time

    if a_completed_time and b_completed_time then
        return b_completed_time < a_completed_time
    elseif a_completed_time then
        return true
    elseif b_completed_time then
        return false
    else
        return a.sort_index < b.sort_index
    end
end

local _achievements_sort_function = function(a, b)
    local a_completed = a.completed
    local b_completed = b.completed

    if a_completed and b_completed then
        return _completion_time_sort_function(a, b)
    elseif a_completed then
        return true
    elseif b_completed then
        return false
    else
        return a.sort_index < b.sort_index
    end
end

local _should_include_achievement = function(achievement_definition, achievement_data)
    return achievement_definition:ui_type() ~= AchievementUITypes.feat_of_strength or achievement_definition:is_visible(achievement_data)
end

-- this is is not directly modified, but I need to change the logic of _ui_achievement(), which is unfortunately a local function
mod:hook(CLASS.AccountService, "get_achievements", function(func, self)
    local get_achievements_promise = self._get_achievements_promise

    if get_achievements_promise:is_pending() then
        return get_achievements_promise
    end

    get_achievements_promise = self:pull_achievement_data():next(function(achievement_data)
        local achievement_definitions = Managers.achievements:get_achievement_definitions()
        local ui_achievements = {}

        for index = 1, #achievement_definitions do
            local achievement_definition = achievement_definitions[index]

            if _should_include_achievement(achievement_definition, achievement_data) then
                local ui_achievement = {
                    id = achievement_definition:id(),
                    type = achievement_definition:ui_type(),
                    sort_index = index,
                    category = achievement_definition:category(),
                    icon = achievement_definition:icon(),
                    label = achievement_definition:label(),
                    description = achievement_definition:description(),
                    progress_current = achievement_definition:get_progress(achievement_data),
                    progress_goal = achievement_definition:get_target(achievement_data),
                    completed = achievement_definition:is_completed(achievement_data),
                    completed_time = achievement_definition:completed_time(achievement_data),
                    hidden = not achievement_definition:is_visible(achievement_data),
                    related_commendation_ids = achievement_definition:get_related_achievements(),
                    rewards = achievement_definition:get_rewards(),
                    score = achievement_definition:score()
                }
                if ui_achievement.id == "flawless_team" then
                    ui_achievement.type = AchievementUITypes.increasing_stat
                end
                ui_achievement.prog_details = _get_prog_details(ui_achievement.id, achievement_data, ui_achievement.progress_current)

                ui_achievements[ui_achievement.id] = ui_achievement
            end
        end

        return ui_achievements
    end)
    self._get_achievements_promise = get_achievements_promise

    return get_achievements_promise
end)

mod:hook(CLASS.AchievementsView, "_populate_achievements_grid", function(func, self, achievements, group_label)
    -- modified from scripts/ui/views/achievements_view/achievements_view
    local blueprints = self._definitions.blueprints
    local layout = {}

    for id, achievement in pairs(achievements) do
        if not achievement.hidden then
            local achievement_context = {
                widget_type = "foldout_achievement",
                achievement = achievement,
                sort_index = achievement.sort_index,
                completed = achievement.completed,
                completed_time = achievement.completed_time,
            }

            local is_completed = achievement.completed
            local is_meta_achievement = achievement.type == AchievementUITypes.meta
            local related_commendation_ids = achievement.related_commendation_ids

            if not is_meta_achievement and #achievement.prog_details > 0 then
                achievement_context.prog_details = achievement.prog_details
            end

            if related_commendation_ids and (is_meta_achievement or is_completed) then
                local all_achievements = self._achievements
                local sub_achievements = {}

                for i = 1, #related_commendation_ids do
                    local related_commendation_id = related_commendation_ids[i]
                    local related_achievement = all_achievements[related_commendation_id]
                    sub_achievements[#sub_achievements + 1] = related_achievement
                end

                achievement_context.sub_achievements = sub_achievements
            end

            local reward_item, item_group = AchievementUIHelper.get_reward_item(achievement)

            if reward_item then
                achievement_context.reward_item = reward_item
                achievement_context.reward_item_group = item_group
            end

            if not achievement_context.sub_achievements and not achievement_context.reward_item and not achievement_context.prog_details then
                achievement_context.widget_type = "normal_achievement"
            end
            layout[#layout + 1] = achievement_context
        end
    end

    local achievement_list_padding = {
        widget_type = "list_padding"
    }
    table.sort(layout, _achievements_sort_function)
    table.insert(layout, 1, achievement_list_padding)
    layout[#layout + 1] = achievement_list_padding

    if group_label then
        table.insert(layout, 2, {
            widget_type = "header",
            display_name = group_label
        })
    end

    self._main_grid_layout = layout

    self._grids[ACHIEVEMENT_GRID]:present_grid_layout(layout, blueprints)
end)
