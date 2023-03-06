return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`WhichMissions` encountered an error loading the Darktide Mod Framework.")

		new_mod("WhichMissions", {
			mod_script       = "WhichMissions/scripts/mods/WhichMissions/WhichMissions",
			mod_data         = "WhichMissions/scripts/mods/WhichMissions/WhichMissions_data",
			mod_localization = "WhichMissions/scripts/mods/WhichMissions/WhichMissions_localization",
		})
	end,
	packages = {},
}
