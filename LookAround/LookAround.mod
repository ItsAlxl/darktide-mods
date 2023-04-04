return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`LookAround` encountered an error loading the Darktide Mod Framework.")

		new_mod("LookAround", {
			mod_script       = "LookAround/scripts/mods/LookAround/LookAround",
			mod_data         = "LookAround/scripts/mods/LookAround/LookAround_data",
			mod_localization = "LookAround/scripts/mods/LookAround/LookAround_localization",
		})
	end,
	packages = {},
}
