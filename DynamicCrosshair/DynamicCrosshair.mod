return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`DynamicCrosshair` encountered an error loading the Darktide Mod Framework.")

		new_mod("DynamicCrosshair", {
			mod_script       = "DynamicCrosshair/scripts/mods/DynamicCrosshair/DynamicCrosshair",
			mod_data         = "DynamicCrosshair/scripts/mods/DynamicCrosshair/DynamicCrosshair_data",
			mod_localization = "DynamicCrosshair/scripts/mods/DynamicCrosshair/DynamicCrosshair_localization",
		})
	end,
	packages = {},
}
