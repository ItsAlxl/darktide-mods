return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`BioPage` encountered an error loading the Darktide Mod Framework.")

		new_mod("BioPage", {
			mod_script       = "BioPage/scripts/mods/BioPage/BioPage",
			mod_data         = "BioPage/scripts/mods/BioPage/BioPage_data",
			mod_localization = "BioPage/scripts/mods/BioPage/BioPage_localization",
		})
	end,
	packages = {},
}
