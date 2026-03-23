return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`LobbyModifierInfo` encountered an error loading the Darktide Mod Framework.")

		new_mod("LobbyModifierInfo", {
			mod_script       = "LobbyModifierInfo/scripts/mods/LobbyModifierInfo/LobbyModifierInfo",
			mod_data         = "LobbyModifierInfo/scripts/mods/LobbyModifierInfo/LobbyModifierInfo_data",
			mod_localization = "LobbyModifierInfo/scripts/mods/LobbyModifierInfo/LobbyModifierInfo_localization",
		})
	end,
	packages = {},
}
