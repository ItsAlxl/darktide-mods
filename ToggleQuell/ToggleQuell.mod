return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`ToggleQuell` encountered an error loading the Darktide Mod Framework.")

		new_mod("ToggleQuell", {
			mod_script       = "ToggleQuell/scripts/mods/ToggleQuell/ToggleQuell",
			mod_data         = "ToggleQuell/scripts/mods/ToggleQuell/ToggleQuell_data",
			mod_localization = "ToggleQuell/scripts/mods/ToggleQuell/ToggleQuell_localization",
		})
	end,
	packages = {},
}
