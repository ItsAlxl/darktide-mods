return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`NoNews` encountered an error loading the Darktide Mod Framework.")

		new_mod("NoNews", {
			mod_script       = "NoNews/scripts/mods/NoNews/NoNews",
			mod_data         = "NoNews/scripts/mods/NoNews/NoNews_data",
			mod_localization = "NoNews/scripts/mods/NoNews/NoNews_localization",
		})
	end,
	packages = {},
}
