return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`PickForMe` encountered an error loading the Darktide Mod Framework.")

		new_mod("PickForMe", {
			mod_script       = "PickForMe/scripts/mods/PickForMe/PickForMe",
			mod_data         = "PickForMe/scripts/mods/PickForMe/PickForMe_data",
			mod_localization = "PickForMe/scripts/mods/PickForMe/PickForMe_localization",
		})
	end,
	packages = {},
}
