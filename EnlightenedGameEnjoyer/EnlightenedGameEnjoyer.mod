return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`EnlightenedGameEnjoyer` encountered an error loading the Darktide Mod Framework.")

		new_mod("EnlightenedGameEnjoyer", {
			mod_script       = "EnlightenedGameEnjoyer/scripts/mods/EnlightenedGameEnjoyer/EnlightenedGameEnjoyer",
			mod_data         = "EnlightenedGameEnjoyer/scripts/mods/EnlightenedGameEnjoyer/EnlightenedGameEnjoyer_data",
			mod_localization = "EnlightenedGameEnjoyer/scripts/mods/EnlightenedGameEnjoyer/EnlightenedGameEnjoyer_localization",
		})
	end,
	packages = {},
}
