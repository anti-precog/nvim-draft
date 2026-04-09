local utils = require("draft.utils")

---@param text string Line to check
---@return boolean is_meta Is the text meta
local function is_meta(text)
	return text:match("^[#].*")
end

-- A submodule for skip lines
---@class Skipper
local M = {}

local prev_line = -1

function M.try_skip()
	local current_line = utils.get_cursor_line_nr()

	if current_line > prev_line then
		local text = vim.fn.getline(current_line)
		if is_meta(text) then
			vim.cmd("normal! j")
		end
	end
	prev_line = current_line
end

return M
