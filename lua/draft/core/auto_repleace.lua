local config = require("draft.config").configuration
local core_config = config.core

local straight_quote = '"'
local quote_open_symbol = "„"
local quote_close_symbol = "”"

local function is_quote_closed_in(line)
	local open_count = select(2, line:gsub(quote_open_symbol, ""))
	local close_count = select(2, line:gsub(quote_close_symbol, ""))

	return open_count == close_count
end

-- a submodule for auto replacement symbols
---@class AutoRepleaceSubmodule
local M = {}

-- init auto replacement of dash symbol
function M.dash_keymap()
	vim.keymap.set("i", core_config.repleace_dash, config.dash_symbol, { buffer = true })
end

-- init auto replacement of smart quotes
function M.quotes_keymap()
	vim.keymap.set("i", straight_quote, function()
		local line = vim.api.nvim_get_current_line()
		if is_quote_closed_in(line) then
			return quote_open_symbol
		else
			return quote_close_symbol
		end
	end, { expr = true, buffer = true })
end

return M
