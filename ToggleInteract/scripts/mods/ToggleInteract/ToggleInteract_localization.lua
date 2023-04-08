local _list_ephemeral_actions = function(delimiter)
	if delimiter == nil then
		delimiter = ", "
	end

	local example_actions = {
		"loc_ingame_action_one",
		"loc_ingame_action_two",
		"loc_ingame_quick_wield",
		"loc_ingame_dodge",
		"loc_ingame_jump",
	}
	for i, act in pairs(example_actions) do
		example_actions[i] = Localize(act)
	end
	return table.concat(example_actions, delimiter)
end

local _get_tooltip_text = function(on)
	local action_params = {
		input = "E",
		action = Localize("loc_action_interaction_use")
	}
	local text
	if on then
		text = "loc_interaction_input_type"
	else
		text = "loc_interaction_input_type_hold"
	end
	return '"' .. Localize(text, true, action_params) .. '"'
end

return {
	mod_description = {
		en = "Held interactions become toggled interactions.",
	},
	interact_cancel = {
		en = "Press Interact again to cancel",
	},
	ephemeral_cancel = {
		en = "Use an ephemeral action to cancel",
	},
	ephemeral_cancel_description = {
		en = "Ephemeral actions include: " .. _list_ephemeral_actions(),
	},
	replace_tooltip = {
		en = "Replace held interaction tooltips",
	},
	replace_tooltip_description = {
		en = "On: " .. _get_tooltip_text(true) .. "\nOff: " .. _get_tooltip_text(false),
	},
}
