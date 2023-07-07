return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`Shirtless` encountered an error loading the Darktide Mod Framework.")

		new_mod("Shirtless", {
			mod_script       = "Shirtless/scripts/mods/Shirtless/Shirtless",
			mod_data         = "Shirtless/scripts/mods/Shirtless/Shirtless_data",
			mod_localization = "Shirtless/scripts/mods/Shirtless/Shirtless_localization",
		})
	end,
	packages = {},
}
