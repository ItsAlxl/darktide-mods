return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`StaminaVis` encountered an error loading the Darktide Mod Framework.")

		new_mod("StaminaVis", {
			mod_script       = "StaminaVis/scripts/mods/StaminaVis/StaminaVis",
			mod_data         = "StaminaVis/scripts/mods/StaminaVis/StaminaVis_data",
			mod_localization = "StaminaVis/scripts/mods/StaminaVis/StaminaVis_localization",
		})
	end,
	packages = {},
}
