return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`AimSensitivity` encountered an error loading the Darktide Mod Framework.")

		new_mod("AimSensitivity", {
			mod_script       = "AimSensitivity/scripts/mods/AimSensitivity/AimSensitivity",
			mod_data         = "AimSensitivity/scripts/mods/AimSensitivity/AimSensitivity_data",
			mod_localization = "AimSensitivity/scripts/mods/AimSensitivity/AimSensitivity_localization",
		})
	end,
	packages = {},
}
