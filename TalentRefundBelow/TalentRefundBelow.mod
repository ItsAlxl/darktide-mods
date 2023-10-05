return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`TalentRefundBelow` encountered an error loading the Darktide Mod Framework.")

		new_mod("TalentRefundBelow", {
			mod_script       = "TalentRefundBelow/scripts/mods/TalentRefundBelow/TalentRefundBelow",
			mod_data         = "TalentRefundBelow/scripts/mods/TalentRefundBelow/TalentRefundBelow_data",
			mod_localization = "TalentRefundBelow/scripts/mods/TalentRefundBelow/TalentRefundBelow_localization",
		})
	end,
	packages = {},
}
