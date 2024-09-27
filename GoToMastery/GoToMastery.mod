return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`GoToMastery` encountered an error loading the Darktide Mod Framework.")

		new_mod("GoToMastery", {
			mod_script       = "GoToMastery/scripts/mods/GoToMastery/GoToMastery",
			mod_data         = "GoToMastery/scripts/mods/GoToMastery/GoToMastery_data",
			mod_localization = "GoToMastery/scripts/mods/GoToMastery/GoToMastery_localization",
		})
	end,
	packages = {},
}
