--[[
The format for a threshold is as follows:
    [0.0 to 1.0] = {
        before = { a, r, g, b },
        after = { a, r, g, b },
    },
Only one of either `before` or `after` need to be defined,
but defining both allows for a sudden color change.

`before` is the color to transition to while approaching the threshold
`after` is the color to transition from after the threshold
`a` = Alpha/opacity, 0-255
`r` = Red, 0-255
`g` = Green, 0-255
`b` = Blue, 0-255

Make sure to back this file up before updating the mod if
you want to bring your thresholds into the new version
--]]

return {
	[0.0] = {
		after = { 200, 255, 255, 255 },
	},
	[0.85] = {
		before = { 255, 225, 200, 80 },
		after = { 255, 250, 100, 0 },
	},
	[1.0] = {
		before = { 255, 255, 0, 0 },
	},
}
