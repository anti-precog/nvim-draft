local typo_config = require("draft.config").configuration.typography
local ns = require("draft.config").namespace

local selected_line = require("draft.typography.line")

-- a submodule to highlight quotes
---@class hl_quotes
local M = {}

local quote_open = "„"
local quote_close = "”"

---@return boolean
function M.make()
	for s, e in selected_line.text:gmatch("()" .. quote_open .. "[^" .. quote_open .. "]+" .. quote_close .. "()") do
		vim.api.nvim_buf_add_highlight(selected_line.buf, ns, typo_config.quote_hl, selected_line.row, s - 1, e - 1)
	end
	return true
end

return M
