return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`StoryReplay` encountered an error loading the Darktide Mod Framework.")

		new_mod("StoryReplay", {
			mod_script       = "StoryReplay/scripts/mods/StoryReplay/StoryReplay",
			mod_data         = "StoryReplay/scripts/mods/StoryReplay/StoryReplay_data",
			mod_localization = "StoryReplay/scripts/mods/StoryReplay/StoryReplay_localization",
		})
	end,
	packages = {},
}
