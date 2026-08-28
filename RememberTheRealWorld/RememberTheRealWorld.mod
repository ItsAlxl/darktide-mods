return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`RememberTheRealWorld` encountered an error loading the Darktide Mod Framework.")

		new_mod("RememberTheRealWorld", {
			mod_script       = "RememberTheRealWorld/scripts/mods/RememberTheRealWorld/RememberTheRealWorld",
			mod_data         = "RememberTheRealWorld/scripts/mods/RememberTheRealWorld/RememberTheRealWorld_data",
			mod_localization = "RememberTheRealWorld/scripts/mods/RememberTheRealWorld/RememberTheRealWorld_localization",
		})
	end,
	packages = {},
}
