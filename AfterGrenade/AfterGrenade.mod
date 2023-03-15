return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`AfterGrenade` encountered an error loading the Darktide Mod Framework.")

		new_mod("AfterGrenade", {
			mod_script       = "AfterGrenade/scripts/mods/AfterGrenade/AfterGrenade",
			mod_data         = "AfterGrenade/scripts/mods/AfterGrenade/AfterGrenade_data",
			mod_localization = "AfterGrenade/scripts/mods/AfterGrenade/AfterGrenade_localization",
		})
	end,
	packages = {},
}
