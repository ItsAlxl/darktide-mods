return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`StickySprint` encountered an error loading the Darktide Mod Framework.")

		new_mod("StickySprint", {
			mod_script       = "StickySprint/scripts/mods/StickySprint/StickySprint",
			mod_data         = "StickySprint/scripts/mods/StickySprint/StickySprint_data",
			mod_localization = "StickySprint/scripts/mods/StickySprint/StickySprint_localization",
		})
	end,
	packages = {},
}
