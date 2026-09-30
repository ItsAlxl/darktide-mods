return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`ShowStats` encountered an error loading the Darktide Mod Framework.")

		new_mod("ShowStats", {
			mod_script       = "ShowStats/scripts/mods/ShowStats/ShowStats",
			mod_data         = "ShowStats/scripts/mods/ShowStats/ShowStats_data",
			mod_localization = "ShowStats/scripts/mods/ShowStats/ShowStats_localization",
		})
	end,
	packages = {},
}
