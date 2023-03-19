return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`Click2Play` encountered an error loading the Darktide Mod Framework.")

		new_mod("Click2Play", {
			mod_script       = "Click2Play/scripts/mods/Click2Play/Click2Play",
			mod_data         = "Click2Play/scripts/mods/Click2Play/Click2Play_data",
			mod_localization = "Click2Play/scripts/mods/Click2Play/Click2Play_localization",
		})
	end,
	packages = {},
}
