local config = require("draft.config").options
local core = config.core

local straight_quote = '"'
local quote_open = "„"
local quote_close = "”"

local function is_quote_closed(line)
	local open_count = select(2, line:gsub(quote_open, ""))
	local close_count = select(2, line:gsub(quote_close, ""))

	return open_count == close_count
end

-- a submodule for auto replacement symbols
---@class auto_repleace
local M = {}

-- init auto replacement of dash symbol
function M.set_dash_key()
	vim.keymap.set("i", core.repleace_dash, config.dash_symbol, { buffer = true })
end

-- init auto replacement of smart quotes
function M.set_smart_quotes()
	vim.keymap.set("i", straight_quote, function()
		local line = vim.api.nvim_get_current_line()
		if is_quote_closed(line) then
			return quote_open
		else
			return quote_close
		end
	end, { expr = true, buffer = true })
end

return M
