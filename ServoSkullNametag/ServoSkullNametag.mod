return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`ServoSkullNametag` encountered an error loading the Darktide Mod Framework.")

		new_mod("ServoSkullNametag", {
			mod_script       = "ServoSkullNametag/scripts/mods/ServoSkullNametag/ServoSkullNametag",
			mod_data         = "ServoSkullNametag/scripts/mods/ServoSkullNametag/ServoSkullNametag_data",
			mod_localization = "ServoSkullNametag/scripts/mods/ServoSkullNametag/ServoSkullNametag_localization",
		})
	end,
	packages = {},
}
