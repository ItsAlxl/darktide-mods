local mod = get_mod("PickForMe")

local ButtonPassTemplates = require("scripts/ui/pass_templates/button_pass_templates")
local UIWidget = require("scripts/managers/ui/ui_widget")

local talent_view = nil

mod:hook_require("scripts/ui/views/talent_builder_view/talent_builder_view_definitions", function(defs)
	local scenegraph = defs.overlay_scenegraph_definition

	local summary_position = scenegraph.info_banner.position
	if summary_position[2] > 220 then
		summary_position[2] = 220
	end

	scenegraph.pickforme = {
		parent = "canvas",
		horizontal_alignment = "left",
		vertical_alignment = "bottom",
		size = {
			300,
			150,
		},
		position = {
			111,
			-120,
			500,
		},
	}
	scenegraph.pickforme_rando = {
		parent = "pickforme",
		horizontal_alignment = "center",
		vertical_alignment = "bottom",
		size = {
			300,
			50,
		},
	}

	defs.widget_definitions.btn_pickforme = UIWidget.create_definition(
		ButtonPassTemplates.terminal_button_small,
		"pickforme_rando",
		{
			text = mod:localize("quick_randomize"),
		}
	)
end)

local _node_has_points = function(tree, node)
	return (tree._node_widget_tiers[node.widget_name] or 0) > 0
end

local _is_valid_selection = function(tree, node)
	return node and not _node_has_points(tree, node) and tree:_node_availability_status(node) == "available"
end

local _randomize_with_strategy = function(tree, strategy_id, points)
	local strategy = mod:io_dofile("PickForMe/scripts/mods/PickForMe/TalentStrategies/" .. strategy_id)(
		_node_has_points,
		_is_valid_selection
	)

	strategy.start(tree, tree:start_node().content.node_data)
	local finished = false
	local stop_at = tree:_points_available() - points
	while not finished do
		if not strategy.is_empty() then
			local next_node = strategy.next()
			if next_node and not _node_has_points(tree, next_node) and _is_valid_selection(tree, next_node) then
				tree:_add_node_point_on_widget(tree._widgets_by_name[next_node.widget_name], 1)
			end
			strategy.on_chosen(tree, next_node)

			finished = tree:_points_available() <= stop_at
		else
			finished = true
		end
	end
	tree._draw_instant_lines = true
	tree:_set_selected_node(nil)
	tree:_refresh_all_nodes()
end

local _randomize_talents = function(strategy, min_points, max_points)
	if not talent_view or talent_view._is_readonly or not talent_view._is_own_player then
		if mod:get("msg_invalid") then
			mod:notify(mod:localize("needs_talent_view"))
		end
		return
	end

	talent_view:clear_node_points()
	if talent_view:_points_available() > 0 then
		strategy = strategy or mod:get("talents_strategy")
		min_points = min_points or mod:get("talents_min")
		max_points = max_points or mod:get("talents_max")

		local points = min_points >= max_points and max_points or math.random(min_points, max_points)
		_randomize_with_strategy(
			talent_view,
			(strategy == "spread" or strategy == "random") and strategy or "major",
			points > 30 and 30 or points
		)
	end
end

mod:hook(CLASS.TalentBuilderView, "on_enter", function(func, self, ...)
	func(self, ...)
	talent_view = self
	self._widgets_by_name.btn_pickforme.content.hotspot.pressed_callback = _randomize_talents
end)

mod:hook(CLASS.TalentBuilderView, "on_exit", function(func, self, ...)
	talent_view = nil
	func(self, ...)
end)

mod:command("pickforme_talents", mod:localize("cmd_desc_talents"), function(...)
	local strategy = nil
	local min = nil
	local max = nil

	local args = { ... }
	local arg_count = #args
	if arg_count > 0 then
		if table.contains(args, "help") then
			mod:echo(mod:localize("cmd_help_talents"))
			return
		end

		for i = 1, #args do
			local a = args[i]

			if not strategy and (a == "random" or a == "spread" or a == "major") then
				strategy = a
			end

			if not min or not max then
				local d = tonumber(a)
				if min then
					max = d
				else
					min = d
				end
			end
		end
	end

	_randomize_talents(strategy, min, max)
end)
