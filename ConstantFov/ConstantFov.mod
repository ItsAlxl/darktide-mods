return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`ConstantFov` encountered an error loading the Darktide Mod Framework.")

		new_mod("ConstantFov", {
			mod_script       = "ConstantFov/scripts/mods/ConstantFov/ConstantFov",
			mod_data         = "ConstantFov/scripts/mods/ConstantFov/ConstantFov_data",
			mod_localization = "ConstantFov/scripts/mods/ConstantFov/ConstantFov_localization",
		})
	end,
	packages = {},
}
