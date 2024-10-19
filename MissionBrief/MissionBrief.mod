return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`MissionBrief` encountered an error loading the Darktide Mod Framework.")

		new_mod("MissionBrief", {
			mod_script       = "MissionBrief/scripts/mods/MissionBrief/MissionBrief",
			mod_data         = "MissionBrief/scripts/mods/MissionBrief/MissionBrief_data",
			mod_localization = "MissionBrief/scripts/mods/MissionBrief/MissionBrief_localization",
		})
	end,
	packages = {},
}
