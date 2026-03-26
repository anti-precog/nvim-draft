local global = require("draft.config")
---@type TypographyConfig
local typo_config = global.configuration.typography

local utils = require("draft.utils")

---@param buf_id integer Buffer handle
---@return boolean status Is buffer filetype draft
local function is_draft_type(buf_id)
	return "draft" == vim.bo[buf_id].filetype
end

---@param buf_id integer Buffer handle
---@param row_id integer Window row position
---@return string text Text from the line
local get_line_text = function(buf_id, row_id)
	return vim.api.nvim_buf_get_lines(buf_id, row_id, row_id + 1, false)[1]
end

---@type Decorator
local decorator

---@param buf_id integer Buffer handle
---@param begin_row_id integer Begin row to start clearing
---@param end_row_id integer End row to stop clearing
local function clear_decoration_for_range(buf_id, begin_row_id, end_row_id)
	vim.api.nvim_buf_clear_namespace(buf_id, global.namespace, begin_row_id, end_row_id + 1)
end

---@param buf_id integer Buffer handle
---@param begin_row_id integer Begin row
---@param end_row_id integer End row
local function get_lines_from_range(buf_id, begin_row_id, end_row_id)
	return vim.api.nvim_buf_get_lines(buf_id, begin_row_id, end_row_id + 1, false)
end

---@param win_id integer Window handle
---@return integer row_id Number of line where cursor is
local function get_cursor_row_id(win_id)
	return vim.api.nvim_win_get_cursor(win_id)[1] - 1
end

---@param buf_id integer Buffer handle
local function setup_post_cr_decore_mapping(buf_id)
	vim.keymap.set({ "i", "s" }, "<CR>", function()
		local win_id = vim.api.nvim_get_current_win()
		local cursor_row_id = get_cursor_row_id(win_id)
		if cursor_row_id >= 0 then
			local text = get_line_text(buf_id, cursor_row_id)

			decorator.set_line(win_id, buf_id, cursor_row_id, text)
			decorator.post_run()
		end
		return vim.api.nvim_replace_termcodes("<CR>", true, false, true)
	end, { buffer = buf_id, expr = true, noremap = true, silent = true })
end

-- Setup for decoration_provider and post CR text formating
---@class TypographyModule Setup for decoration_provider and post CR text formating
local M = {}

-- init module
function M.setup()
	decorator = require("draft.typography.decorator").init()

	vim.api.nvim_set_decoration_provider(global.namespace, {

		on_win = function(_, win_id, buf_id, top_row_id, bottom_row_id)
			if not is_draft_type(buf_id) then
				return false -- stop
			end

			if utils.is_insert_mode() then
				return true -- skip to on_line
			end

			clear_decoration_for_range(buf_id, top_row_id, bottom_row_id)
			local visable_lines = get_lines_from_range(buf_id, top_row_id, bottom_row_id)

			for line_nr, text in ipairs(visable_lines) do
				local row_id = top_row_id + line_nr - 1
				decorator.set_line(win_id, buf_id, row_id, text)
				decorator.run(false)
			end
			return false -- stop
		end,

		on_line = function(_, win_id, buf_id, row_id)
			local cursor_row_id = get_cursor_row_id(win_id)

			if cursor_row_id == row_id then
				local text = get_line_text(buf_id, row_id)

				decorator.set_line(win_id, buf_id, row_id, text)
				decorator.run(true)
			end
		end,
	})
	if typo_config.center_asterix or typo_config.center_header then
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "draft",
			callback = function(args)
				setup_post_cr_decore_mapping(args.buf)
			end,
			desc = "post <CR> decorate",
		})
	end
end

return M
