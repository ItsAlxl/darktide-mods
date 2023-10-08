return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`IgnorePsykerGrenades` encountered an error loading the Darktide Mod Framework.")

		new_mod("IgnorePsykerGrenades", {
			mod_script       = "IgnorePsykerGrenades/scripts/mods/IgnorePsykerGrenades/IgnorePsykerGrenades",
			mod_data         = "IgnorePsykerGrenades/scripts/mods/IgnorePsykerGrenades/IgnorePsykerGrenades_data",
			mod_localization = "IgnorePsykerGrenades/scripts/mods/IgnorePsykerGrenades/IgnorePsykerGrenades_localization",
		})
	end,
	packages = {},
}
