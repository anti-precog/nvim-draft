local config = require("draft.config").options.typography
local ns = require("draft.config").namespace

local line = require("draft.typography.line")

-- a submodule to highlight quotes
---@class hl_quotes
local M = {}

local quote_open = "„"
local quote_close = "”"

---@return boolean
function M.make()
	for s, e in line.text:gmatch("()" .. quote_open .. "[^" .. quote_open .. "]+" .. quote_close .. "()") do
		vim.api.nvim_buf_add_highlight(line.buf, ns, config.quote_hl, line.row, s - 1, e - 1)
	end
	return true
end

return M
