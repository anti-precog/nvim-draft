local config = require("draft.config").options.typography
local ns = require("draft.config").namespace

local line = require("draft.typography.line")

---@return boolean
local function is_comment()
	return line.text:match("^[\t ].*")
end

-- a submodule to highlight comments
---@class hl_comment
local M = {}

---@return boolean
function M.try_make()
	if is_comment() then
		vim.api.nvim_buf_add_highlight(line.buf, ns, config.comment_hl, line.row, 0, #line.text)
		return false
	end
	return true
end

return M
