return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`PenanceDetails` encountered an error loading the Darktide Mod Framework.")

		new_mod("PenanceDetails", {
			mod_script       = "PenanceDetails/scripts/mods/PenanceDetails/PenanceDetails",
			mod_data         = "PenanceDetails/scripts/mods/PenanceDetails/PenanceDetails_data",
			mod_localization = "PenanceDetails/scripts/mods/PenanceDetails/PenanceDetails_localization",
		})
	end,
	packages = {},
}
