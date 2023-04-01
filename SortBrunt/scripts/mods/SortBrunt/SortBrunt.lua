local mod = get_mod("SortBrunt")

mod:hook(CLASS.CreditsGoodsVendorView, "_convert_offers_to_layout_entries", function(func, self, item_offers)
    local layout = func(self, item_offers)
    table.sort(layout, function(a, b)
        return a.item.weapon_template > b.item.weapon_template
    end)
    return layout
end)
