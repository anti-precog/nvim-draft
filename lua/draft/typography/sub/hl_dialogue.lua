--@type table
local config = require("draft.config").configuration
local typo_config = config.typography
local ns = require("draft.config").namespace

local selected_line = require("draft.typography.line")

local function is_start_with_dash()
	return selected_line.text:match("^" .. config.dash_symbol .. ".*")
end

-- a submodule to highlight dialogues
---@class hl_dialogue
local M = {}

---@return boolean
function M.make()
	if not is_start_with_dash() then
		return true
	end

	local line_len = #selected_line.text
	local pos = 1

	while pos <= line_len do
		local s, e = selected_line.text:find(config.dash_symbol, pos, true) -- first dash
		if not s then
			break
		end

		local next_s, next_e = selected_line.text:find(config.dash_symbol, e + 1, true) -- second dash
		if next_s then
			vim.api.nvim_buf_add_highlight(
				selected_line.buf,
				ns,
				typo_config.dialogue_hl,
				selected_line.row,
				s - 1,
				next_e
			)
			pos = next_e + 1
		else
			-- if there is no second dash
			vim.api.nvim_buf_add_highlight(
				selected_line.buf,
				ns,
				typo_config.dialogue_hl,
				selected_line.row,
				s - 1,
				line_len
			)
			break
		end
	end
	return true
end

return M
