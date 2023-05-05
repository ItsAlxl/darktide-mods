local mod = get_mod("PlaystationPrompts")

local replace = {
    [""] = "O", -- B
    [""] = "▲", -- Y
    [""] = "■", -- X
    [""] = "X", -- A
}

mod:hook_require("scripts/managers/input/input_utils", function(InputUtils)
    mod:hook(InputUtils, "localized_button_name", function(func, index, device)
        local bname = func(index, device)
        return replace[bname] or bname
    end)
end)
