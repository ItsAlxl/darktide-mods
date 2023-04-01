return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`SortBrunt` encountered an error loading the Darktide Mod Framework.")

		new_mod("SortBrunt", {
			mod_script       = "SortBrunt/scripts/mods/SortBrunt/SortBrunt",
			mod_data         = "SortBrunt/scripts/mods/SortBrunt/SortBrunt_data",
			mod_localization = "SortBrunt/scripts/mods/SortBrunt/SortBrunt_localization",
		})
	end,
	packages = {},
}
