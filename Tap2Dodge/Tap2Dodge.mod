return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`Tap2Dodge` encountered an error loading the Darktide Mod Framework.")

		new_mod("Tap2Dodge", {
			mod_script       = "Tap2Dodge/scripts/mods/Tap2Dodge/Tap2Dodge",
			mod_data         = "Tap2Dodge/scripts/mods/Tap2Dodge/Tap2Dodge_data",
			mod_localization = "Tap2Dodge/scripts/mods/Tap2Dodge/Tap2Dodge_localization",
		})
	end,
	packages = {},
}
