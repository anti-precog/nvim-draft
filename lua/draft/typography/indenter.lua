local typo = require("draft.config").options.typography
local ns = require("draft.config").namespace
local line = require("draft.typography.line")

---@return string
local indent = string.rep(" ", typo.indent_size)

-- a submodule to make indents
---@class indenter
local M = {}

---@return boolean
function M.make_indent()
	vim.api.nvim_buf_set_extmark(line.buf, ns, line.row, 0, {
		--virt_text = { { "->" .. draw_counter[row_nr] .. " ", "NonText" } }, -- debug
		virt_text = { { indent, "NonText" } },
		virt_text_pos = "inline",
		hl_mode = "combine",
	})
	return true
end
return M
