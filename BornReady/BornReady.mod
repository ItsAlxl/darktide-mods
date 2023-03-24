return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`BornReady` encountered an error loading the Darktide Mod Framework.")

		new_mod("BornReady", {
			mod_script       = "BornReady/scripts/mods/BornReady/BornReady",
			mod_data         = "BornReady/scripts/mods/BornReady/BornReady_data",
			mod_localization = "BornReady/scripts/mods/BornReady/BornReady_localization",
		})
	end,
	packages = {},
}
