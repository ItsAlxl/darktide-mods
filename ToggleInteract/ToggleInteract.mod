return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`ToggleInteract` encountered an error loading the Darktide Mod Framework.")

		new_mod("ToggleInteract", {
			mod_script       = "ToggleInteract/scripts/mods/ToggleInteract/ToggleInteract",
			mod_data         = "ToggleInteract/scripts/mods/ToggleInteract/ToggleInteract_data",
			mod_localization = "ToggleInteract/scripts/mods/ToggleInteract/ToggleInteract_localization",
		})
	end,
	packages = {},
}
