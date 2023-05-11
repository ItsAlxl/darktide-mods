local mod = get_mod("CharWallets")

mod.DEFAULT_CURRENCY_ORDER = {
	"credits",
	"marks",
	"plasteel",
	"diamantine",
}

local show_opts = {}
local order_opts = {}

local _add_show_opt = function(currency_name)
	show_opts[#show_opts + 1] = {
		setting_id    = "show_" .. currency_name,
		title         = "currency_" .. currency_name,
		type          = "checkbox",
		default_value = true,
	}
end

local _add_order_opt = function(currency_name, def_idx)
	order_opts[#order_opts + 1] = {
		setting_id    = "order_" .. currency_name,
		title         = "currency_" .. currency_name,
		type          = "numeric",
		default_value = def_idx,
		range         = { 1, 4 },
	}
end

for idx, currency in ipairs(mod.DEFAULT_CURRENCY_ORDER) do
	_add_show_opt(currency)
	_add_order_opt(currency, idx)
end
_add_show_opt("contracts")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id    = "limit_digits",
				type          = "checkbox",
				default_value = true,
			},
			{
				setting_id  = "options_vis",
				type        = "group",
				sub_widgets = show_opts
			},
			{
				setting_id  = "options_order",
				type        = "group",
				sub_widgets = order_opts
			},
			{
				setting_id  = "options_spacing",
				type        = "group",
				sub_widgets = {
					{
						setting_id    = "start_x",
						type          = "numeric",
						default_value = 0,
						range         = { -25, 25 },
					},
					{
						setting_id    = "size_x",
						type          = "numeric",
						default_value = 0,
						range         = { -50, 50 },
					},
					{
						setting_id    = "contracts_x",
						type          = "numeric",
						default_value = 0,
						range         = { -25, 25 },
					},
				}
			},
		}
	}
}
