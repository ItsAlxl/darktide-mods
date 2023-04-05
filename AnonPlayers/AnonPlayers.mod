return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`AnonPlayers` encountered an error loading the Darktide Mod Framework.")

		new_mod("AnonPlayers", {
			mod_script       = "AnonPlayers/scripts/mods/AnonPlayers/AnonPlayers",
			mod_data         = "AnonPlayers/scripts/mods/AnonPlayers/AnonPlayers_data",
			mod_localization = "AnonPlayers/scripts/mods/AnonPlayers/AnonPlayers_localization",
		})
	end,
	packages = {},
}
