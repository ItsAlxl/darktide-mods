return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`FullAuto` encountered an error loading the Darktide Mod Framework.")

		new_mod("FullAuto", {
			mod_script       = "FullAuto/scripts/mods/FullAuto/FullAuto",
			mod_data         = "FullAuto/scripts/mods/FullAuto/FullAuto_data",
			mod_localization = "FullAuto/scripts/mods/FullAuto/FullAuto_localization",
		})
	end,
	packages = {},
}
