--@type table
local config = require("draft.config").options
local typo = config.typography
local ns = require("draft.config").namespace

local line = require("draft.typography.line")

local function is_start_with_dash()
	return line.text:match("^" .. config.dash_symbol .. ".*")
end

-- a submodule to highlight dialogues
---@class hl_dialogue
local M = {}

---@return boolean
function M.make()
	if not is_start_with_dash() then
		return true
	end

	local line_len = #line.text
	local pos = 1

	while pos <= line_len do
		local s, e = line.text:find(config.dash_symbol, pos, true) -- first dash
		if not s then
			break
		end

		local next_s, next_e = line.text:find(config.dash_symbol, e + 1, true) -- second dash
		if next_s then
			vim.api.nvim_buf_add_highlight(line.buf, ns, typo.dialogue_hl, line.row, s - 1, next_e)
			pos = next_e + 1
		else
			-- if there is no second dash
			vim.api.nvim_buf_add_highlight(line.buf, ns, typo.dialogue_hl, line.row, s - 1, line_len)
			break
		end
	end
	return true
end

return M
