return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`EmoteBoard` encountered an error loading the Darktide Mod Framework.")

		new_mod("EmoteBoard", {
			mod_script       = "EmoteBoard/scripts/mods/EmoteBoard/EmoteBoard",
			mod_data         = "EmoteBoard/scripts/mods/EmoteBoard/EmoteBoard_data",
			mod_localization = "EmoteBoard/scripts/mods/EmoteBoard/EmoteBoard_localization",
		})
	end,
	packages = {},
}
