return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`TagKeys` encountered an error loading the Darktide Mod Framework.")

		new_mod("TagKeys", {
			mod_script       = "TagKeys/scripts/mods/TagKeys/TagKeys",
			mod_data         = "TagKeys/scripts/mods/TagKeys/TagKeys_data",
			mod_localization = "TagKeys/scripts/mods/TagKeys/TagKeys_localization",
		})
	end,
	packages = {},
}
