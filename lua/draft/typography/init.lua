local config = require("draft.config").configuration
local ns = require("draft.config").namespace

local decorator

---@return boolean
local is_insert_mode = function()
	return vim.api.nvim_get_mode().mode == "i"
end

---@param buf_nr number
---@return boolean
local function is_correct_ft(buf_nr)
	local current_ft = vim.bo[buf_nr].filetype
	for _, ft in ipairs(config.filetypes) do
		if current_ft == ft then
			return true
		end
	end
	return false
end

---@param buf_nr number
---@param row_nr number
---@return string
local get_line_text = function(buf_nr, row_nr)
	return vim.api.nvim_buf_get_lines(buf_nr, row_nr, row_nr + 1, false)[1]
end

---@param buf_nr number
local function set_post_CR_decore(buf_nr)
	vim.keymap.set({ "i", "s" }, "<CR>", function()
		local win_id = vim.api.nvim_get_current_win()
		local cursor_line_nr = vim.api.nvim_win_get_cursor(win_id)[1] - 1
		if cursor_line_nr >= 0 then
			local text = get_line_text(buf_nr, cursor_line_nr)

			decorator.set_line(win_id, buf_nr, cursor_line_nr, text)
			decorator.post_run()
		end
		return vim.api.nvim_replace_termcodes("<CR>", true, false, true)
	end, { buffer = buf_nr, expr = true, noremap = true, silent = true })
end

---@class TypographyModule
local M = {}

function M.setup()
	local typo_config = config.typography
	decorator = require("draft.typography.decorator").setup()

	vim.api.nvim_set_decoration_provider(ns, {

		on_win = function(_, win_id, buf_nr, toprow, botrow)
			if not is_correct_ft(buf_nr) then
				return false -- stop all
			end

			if is_insert_mode() then
				return true -- goto on_line
			end

			vim.api.nvim_buf_clear_namespace(buf_nr, ns, toprow, botrow + 1)

			local lines = vim.api.nvim_buf_get_lines(buf_nr, toprow, botrow + 1, false)
			for i, text in ipairs(lines) do
				local row_nr = toprow + i - 1
				--draw_counter[row_nr] = (draw_counter[row_nr] or 0) + 1 -- debug
				decorator.set_line(win_id, buf_nr, row_nr, text)
				decorator.run(false)
			end
			return false
		end,

		on_line = function(_, win_id, buf_nr, row_nr)
			local cursor_line = vim.api.nvim_win_get_cursor(win_id)[1] - 1

			if cursor_line == row_nr then
				--draw_counter[row_nr] = (draw_counter[row_nr] or 0) + 1 -- debug
				local text = get_line_text(buf_nr, row_nr)

				decorator.set_line(win_id, buf_nr, row_nr, text)
				decorator.run(true)
			end
		end,
	})
	if typo_config.center_asterix or typo_config.center_header then
		vim.api.nvim_create_autocmd("FileType", {
			pattern = config.filetypes,
			callback = function(args)
				set_post_CR_decore(args.buf)
			end,
			desc = "post <CR> decorate",
		})
	end
end

return M
