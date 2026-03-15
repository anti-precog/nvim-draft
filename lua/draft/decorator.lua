---@module "decorator"
local M = {}

local ns = vim.api.nvim_create_namespace("draft")

-- PERF: Idea to optimalize: make cache for line during cursor position change

---@param line string
---@return boolean
local function is_comment(line)
	return line:match("^[\t ].*")
end

---@param line string
---@return boolean
local function is_header(line)
	return line:match("^[A-Z].*[^.]$")
end

---@param hl_group string
---@param buf_nr string
---@param row_nr number
---@param start number | nil
---@param stop number | nil
local function highlight_as(hl_group, buf_nr, row_nr, start, stop)
	start = start or 0
	stop = stop or -1
	vim.api.nvim_buf_add_highlight(buf_nr, ns, hl_group, row_nr, start, stop)
end

local get_line = function(buf_nr, row_nr)
	return vim.api.nvim_buf_get_lines(buf_nr, row_nr, row_nr + 1, false)[1]
end

local draw_counter = {} -- debug
---@param buf string
---@param line_nr number
---@param length number
local function make_indent(buf_nr, row_nr, length)
	-- draw_counter[row_nr] = (draw_counter[row_nr] or 0) + 1 -- debug
	local space = string.rep(" ", length)
	vim.api.nvim_buf_set_extmark(buf_nr, ns, row_nr, 0, {
		-- virt_text = { { "->" .. draw_counter[row_nr] .. " ", "NonText" } }, -- debug
		virt_text = { { space, "NonText" } },
		virt_text_pos = "inline",
		hl_mode = "combine",
	})
end

local function make_quotes(buf_nr, row_nr, line)
	for s, e in line:gmatch('()"[^"]+"()') do
		highlight_as("Statement", buf_nr, row_nr, s - 1, e - 1)
	end
end

local function make_dialogues(buf_nr, row_nr, line)
	local line_len = #line
	local pos = 1

	while pos <= line_len do
		local s, e = line:find("—", pos, true) -- pierwsz pałza
		if not s then
			break
		end

		local next_s, next_e = line:find("—", e + 1, true) -- dugia pałza
		if next_s then
			highlight_as("Statement", buf_nr, row_nr, s - 1, next_e)
			pos = next_e + 1
		else
			-- jeśli nie ma drugiej pałzy
			highlight_as("Statement", buf_nr, row_nr, s - 1, line_len)
			break
		end
	end
end
local function decore_row(buf_nr, row_nr)
	vim.api.nvim_buf_clear_namespace(buf_nr, -1, row_nr, row_nr + 1)

	local line = get_line(buf_nr, row_nr)
	if is_comment(line) then
		vim.api.nvim_buf_add_highlight(buf_nr, ns, "NonText", row_nr, 0, #line)
	else
		make_indent(buf_nr, row_nr, 2)
		make_quotes(buf_nr, row_nr, line)
		make_dialogues(buf_nr, row_nr, line)
	end
end

local first_load = true
vim.api.nvim_set_decoration_provider(ns, {

	on_line = function(_, win_id, buf_nr, row_nr)
		local cursor_line = vim.api.nvim_win_get_cursor(win_id)[1] - 1

		if cursor_line == row_nr or first_load then
			decore_row(buf_nr, row_nr)
		end
	end,
	on_end = function()
		first_load = false
	end,
})
