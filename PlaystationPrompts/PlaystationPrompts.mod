return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`PlaystationPrompts` encountered an error loading the Darktide Mod Framework.")

		new_mod("PlaystationPrompts", {
			mod_script       = "PlaystationPrompts/scripts/mods/PlaystationPrompts/PlaystationPrompts",
			mod_data         = "PlaystationPrompts/scripts/mods/PlaystationPrompts/PlaystationPrompts_data",
			mod_localization = "PlaystationPrompts/scripts/mods/PlaystationPrompts/PlaystationPrompts_localization",
		})
	end,
	packages = {},
}
