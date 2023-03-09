return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`TruePeril` encountered an error loading the Darktide Mod Framework.")

		new_mod("TruePeril", {
			mod_script       = "TruePeril/scripts/mods/TruePeril/TruePeril",
			mod_data         = "TruePeril/scripts/mods/TruePeril/TruePeril_data",
			mod_localization = "TruePeril/scripts/mods/TruePeril/TruePeril_localization",
		})
	end,
	packages = {},
}
