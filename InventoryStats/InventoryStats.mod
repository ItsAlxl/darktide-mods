return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`InventoryStats` encountered an error loading the Darktide Mod Framework.")

		new_mod("InventoryStats", {
			mod_script       = "InventoryStats/scripts/mods/InventoryStats/InventoryStats",
			mod_data         = "InventoryStats/scripts/mods/InventoryStats/InventoryStats_data",
			mod_localization = "InventoryStats/scripts/mods/InventoryStats/InventoryStats_localization",
		})
	end,
	packages = {},
}
