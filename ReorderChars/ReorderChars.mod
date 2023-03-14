return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`ReorderChars` encountered an error loading the Darktide Mod Framework.")

		new_mod("ReorderChars", {
			mod_script       = "ReorderChars/scripts/mods/ReorderChars/ReorderChars",
			mod_data         = "ReorderChars/scripts/mods/ReorderChars/ReorderChars_data",
			mod_localization = "ReorderChars/scripts/mods/ReorderChars/ReorderChars_localization",
		})
	end,
	packages = {},
}
