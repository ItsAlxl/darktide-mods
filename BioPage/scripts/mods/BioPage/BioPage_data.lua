local mod = get_mod("BioPage")

local widgets = {}

local choice_order = {
	"archetype",
	"home_planet",
	"childhood",
	"growing_up",
	"formative_event",
	"crime",
	"personality",
	"summary",
}
for i = 1, #choice_order do
	local k = choice_order[i]
	widgets[#widgets + 1] = {
		setting_id = k,
		type = "checkbox",
		default_value = k ~= "summary",
	}
end

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = widgets
	}
}
