local mod = get_mod("SortBrunt")

mod:hook(CLASS.CreditsGoodsVendorView, "_convert_offers_to_layout_entries", function(func, self, item_offers)
	local layout = func(self, item_offers)
	table.sort(layout, function(a, b)
		return a.item.weapon_template > b.item.weapon_template
	end)
	return layout
end)

local _sort_masteries = function(a, b)
	return a.mastery_id > b.mastery_id
end

mod:hook_safe(CLASS.MasteriesOverviewView, "_setup_layout_entries", function(self)
	table.sort(self._masteries_layout, _sort_masteries)
end)

mod:hook(CLASS.CraftingMechanicusBarterItemsView, "_setup_menu_tabs", function(func, self, ...)
	table.sort(self._patterns_layout, _sort_masteries)
	func(self, ...)
end)
