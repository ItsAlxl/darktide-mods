return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`CharWallets` encountered an error loading the Darktide Mod Framework.")

		new_mod("CharWallets", {
			mod_script       = "CharWallets/scripts/mods/CharWallets/CharWallets",
			mod_data         = "CharWallets/scripts/mods/CharWallets/CharWallets_data",
			mod_localization = "CharWallets/scripts/mods/CharWallets/CharWallets_localization",
		})
	end,
	packages = {},
}
