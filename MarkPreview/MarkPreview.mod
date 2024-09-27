return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`MarkPreview` encountered an error loading the Darktide Mod Framework.")

		new_mod("MarkPreview", {
			mod_script       = "MarkPreview/scripts/mods/MarkPreview/MarkPreview",
			mod_data         = "MarkPreview/scripts/mods/MarkPreview/MarkPreview_data",
			mod_localization = "MarkPreview/scripts/mods/MarkPreview/MarkPreview_localization",
		})
	end,
	packages = {},
}
