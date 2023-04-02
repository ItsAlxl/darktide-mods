return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`Perspectives` encountered an error loading the Darktide Mod Framework.")

		new_mod("Perspectives", {
			mod_script       = "Perspectives/scripts/mods/Perspectives/Perspectives",
			mod_data         = "Perspectives/scripts/mods/Perspectives/Perspectives_data",
			mod_localization = "Perspectives/scripts/mods/Perspectives/Perspectives_localization",
		})
	end,
	packages = {},
}
