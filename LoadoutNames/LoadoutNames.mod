return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`LoadoutNames` encountered an error loading the Darktide Mod Framework.")

		new_mod("LoadoutNames", {
			mod_script       = "LoadoutNames/scripts/mods/LoadoutNames/LoadoutNames",
			mod_data         = "LoadoutNames/scripts/mods/LoadoutNames/LoadoutNames_data",
			mod_localization = "LoadoutNames/scripts/mods/LoadoutNames/LoadoutNames_localization",
		})
	end,
	packages = {},
}
