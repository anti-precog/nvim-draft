local utils = require("draft.utils")

---@param text string Line to check
---@return boolean is_meta Is the text meta
local function is_meta(text)
	return text:match("^[@#].*")
end

-- A submodule for skip lines
---@class Skipper
local M = {}

local prev_line = -1

function M.try_skip()
	local current_line = utils.get_cursor_line_nr()
	local last_line = utils.get_last_line_nr()

	if current_line > prev_line then
		local text = vim.fn.getline(current_line)
		while is_meta(text) do
			vim.cmd("normal! j")
			if current_line == last_line then
				break
			end
			current_line = utils.get_cursor_line_nr()
			text = vim.fn.getline(current_line)
		end
	end
	prev_line = current_line
end

return M
