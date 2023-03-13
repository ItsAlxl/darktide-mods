return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`BetterMelk` encountered an error loading the Darktide Mod Framework.")

		new_mod("BetterMelk", {
			mod_script       = "BetterMelk/scripts/mods/BetterMelk/BetterMelk",
			mod_data         = "BetterMelk/scripts/mods/BetterMelk/BetterMelk_data",
			mod_localization = "BetterMelk/scripts/mods/BetterMelk/BetterMelk_localization",
		})
	end,
	packages = {},
}
