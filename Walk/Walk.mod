return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`Walk` encountered an error loading the Darktide Mod Framework.")

		new_mod("Walk", {
			mod_script       = "Walk/scripts/mods/Walk/Walk",
			mod_data         = "Walk/scripts/mods/Walk/Walk_data",
			mod_localization = "Walk/scripts/mods/Walk/Walk_localization",
		})
	end,
	packages = {},
}
