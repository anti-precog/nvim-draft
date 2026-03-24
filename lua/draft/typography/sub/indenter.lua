local typo_config = require("draft.config").configuration.typography
local ns = require("draft.config").namespace
local selected_line = require("draft.typography.line")

---@return string
local space = string.rep(" ", typo_config.indent_size)

-- a submodule to make indents
---@class indenter
local M = {}

---@return boolean
function M.make_indent()
	vim.api.nvim_buf_set_extmark(selected_line.buf, ns, selected_line.row, 0, {
		--virt_text = { { "->" .. draw_counter[row_nr] .. " ", "NonText" } }, -- debug
		virt_text = { { space, "NonText" } },
		virt_text_pos = "inline",
		hl_mode = "combine",
	})
	return true
end
return M
