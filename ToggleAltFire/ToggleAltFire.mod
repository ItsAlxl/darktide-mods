return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`ToggleAltFire` encountered an error loading the Darktide Mod Framework.")

		new_mod("ToggleAltFire", {
			mod_script       = "ToggleAltFire/scripts/mods/ToggleAltFire/ToggleAltFire",
			mod_data         = "ToggleAltFire/scripts/mods/ToggleAltFire/ToggleAltFire_data",
			mod_localization = "ToggleAltFire/scripts/mods/ToggleAltFire/ToggleAltFire_localization",
		})
	end,
	packages = {},
}
