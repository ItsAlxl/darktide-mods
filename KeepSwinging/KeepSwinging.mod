return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`KeepSwinging` encountered an error loading the Darktide Mod Framework.")

		new_mod("KeepSwinging", {
			mod_script       = "KeepSwinging/scripts/mods/KeepSwinging/KeepSwinging",
			mod_data         = "KeepSwinging/scripts/mods/KeepSwinging/KeepSwinging_data",
			mod_localization = "KeepSwinging/scripts/mods/KeepSwinging/KeepSwinging_localization",
		})
	end,
	packages = {},
}
