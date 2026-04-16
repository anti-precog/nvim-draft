local global = require("draft.config")
local selected_line = require("draft.typography.line")

---@return boolean is_group Is actual decorated line group head
local function is_group_head()
	return selected_line.text:match("^[@].*")
end

---@return boolean is_group Is above decorated line group head
local function is_group_head_above()
	local row_id = selected_line.row_id
	if row_id == 0 then
		return false
	end
	local row_above = row_id - 1
	local text = vim.api.nvim_buf_get_lines(0, row_above, row_above + 1, false)[1]

	return text:match("^[@].*")
end

---@return boolean is_end_group Is actual decorated line end group
local function is_end_group()
	return selected_line.text:match("^@$")
end

---@return boolean is_tag Is actual decorated line tag
local function is_tag()
	return selected_line.text:match("^[#].*")
end

-- a submodule to highlight comments
---@deprecated Use treesitter_integration
---@class HLComment
local M = {}

-- Add icon to next row
---@return NextStep next_step Return true if is NOT a comment
function M.try_set_icon()
	local next_row = selected_line.row_id + 1
	local icons = ""
	if is_end_group() then
		icons = "—"
	elseif is_group_head() then
		icons = "↓"
	end
	if is_tag() then
		if is_group_head_above() then
			icons = "↓"
		end
		icons = icons .. "#"
	end
	if icons ~= "" then
		vim.api.nvim_buf_set_extmark(selected_line.buf_id, global.namespace, next_row, 0, {
			sign_text = icons,
			sign_hl_group = "NonText",
		})
		return false
	end

	return true
end

return M
