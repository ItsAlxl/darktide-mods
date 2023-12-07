return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`PanicStimm` encountered an error loading the Darktide Mod Framework.")

		new_mod("PanicStimm", {
			mod_script       = "PanicStimm/scripts/mods/PanicStimm/PanicStimm",
			mod_data         = "PanicStimm/scripts/mods/PanicStimm/PanicStimm_data",
			mod_localization = "PanicStimm/scripts/mods/PanicStimm/PanicStimm_localization",
		})
	end,
	packages = {},
}
