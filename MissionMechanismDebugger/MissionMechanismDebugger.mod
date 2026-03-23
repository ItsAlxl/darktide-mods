return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`MissionMechanismDebugger` encountered an error loading the Darktide Mod Framework.")

		new_mod("MissionMechanismDebugger", {
			mod_script       = "MissionMechanismDebugger/scripts/mods/MissionMechanismDebugger/MissionMechanismDebugger",
			mod_data         = "MissionMechanismDebugger/scripts/mods/MissionMechanismDebugger/MissionMechanismDebugger_data",
			mod_localization = "MissionMechanismDebugger/scripts/mods/MissionMechanismDebugger/MissionMechanismDebugger_localization",
		})
	end,
	packages = {},
}
