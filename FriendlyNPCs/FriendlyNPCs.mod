return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`FriendlyNPCs` encountered an error loading the Darktide Mod Framework.")

		new_mod("FriendlyNPCs", {
			mod_script       = "FriendlyNPCs/scripts/mods/FriendlyNPCs/FriendlyNPCs",
			mod_data         = "FriendlyNPCs/scripts/mods/FriendlyNPCs/FriendlyNPCs_data",
			mod_localization = "FriendlyNPCs/scripts/mods/FriendlyNPCs/FriendlyNPCs_localization",
		})
	end,
	packages = {},
}
