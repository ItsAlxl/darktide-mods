return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`PerilGauge` encountered an error loading the Darktide Mod Framework.")

		new_mod("PerilGauge", {
			mod_script       = "PerilGauge/scripts/mods/PerilGauge/PerilGauge",
			mod_data         = "PerilGauge/scripts/mods/PerilGauge/PerilGauge_data",
			mod_localization = "PerilGauge/scripts/mods/PerilGauge/PerilGauge_localization",
		})
	end,
	packages = {},
}
