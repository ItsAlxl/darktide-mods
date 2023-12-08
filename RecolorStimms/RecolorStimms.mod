return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`RecolorStimms` encountered an error loading the Darktide Mod Framework.")

		new_mod("RecolorStimms", {
			mod_script       = "RecolorStimms/scripts/mods/RecolorStimms/RecolorStimms",
			mod_data         = "RecolorStimms/scripts/mods/RecolorStimms/RecolorStimms_data",
			mod_localization = "RecolorStimms/scripts/mods/RecolorStimms/RecolorStimms_localization",
		})
	end,
	packages = {},
}
