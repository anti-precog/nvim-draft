local typo_config = require("draft.config").configuration.typography
local ns = require("draft.config").namespace

local selected_line = require("draft.typography.line")

---@return boolean
local function is_comment()
	return selected_line.text:match("^[\t ].*")
end

-- a submodule to highlight comments
---@class HLCommentSubModule
local M = {}

---@return boolean
function M.try_make()
	if is_comment() then
		vim.api.nvim_buf_add_highlight(
			selected_line.buf,
			ns,
			typo_config.comment_hl,
			selected_line.row,
			0,
			#selected_line.text
		)
		return false
	end
	return true
end

return M
