return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`MissionGrid` encountered an error loading the Darktide Mod Framework.")

		new_mod("MissionGrid", {
			mod_script       = "MissionGrid/scripts/mods/MissionGrid/MissionGrid",
			mod_data         = "MissionGrid/scripts/mods/MissionGrid/MissionGrid_data",
			mod_localization = "MissionGrid/scripts/mods/MissionGrid/MissionGrid_localization",
		})
	end,
	packages = {},
}
