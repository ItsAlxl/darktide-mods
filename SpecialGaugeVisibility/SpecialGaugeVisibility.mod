return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`SpecialGaugeVisibility` encountered an error loading the Darktide Mod Framework.")

		new_mod("SpecialGaugeVisibility", {
			mod_script       = "SpecialGaugeVisibility/scripts/mods/SpecialGaugeVisibility/SpecialGaugeVisibility",
			mod_data         = "SpecialGaugeVisibility/scripts/mods/SpecialGaugeVisibility/SpecialGaugeVisibility_data",
			mod_localization = "SpecialGaugeVisibility/scripts/mods/SpecialGaugeVisibility/SpecialGaugeVisibility_localization",
		})
	end,
	packages = {},
}
