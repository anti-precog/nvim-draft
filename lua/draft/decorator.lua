---@module "decorator"
local M = {}

local ns = vim.api.nvim_create_namespace("fiction")

local start_i = 0
local buf_i = 0
local win_i = 0
local line_i = 0
local end_i = 0
-- end

local draft_ns = vim.api.nvim_create_namespace("draft")

---@param buf string
---@param line_nr number
---@param length number
local function make_indent(buf, line_nr, length)
	local space = string.rep(" ", length)
	vim.api.nvim_buf_set_extmark(buf, draft_ns, line_nr - 1, 0, {
		virt_text = { { space, "NonText" } },
		virt_text_pos = "inline",
		hl_mode = "combine",
	})
end

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
---@param buf string
---@param line_nr number
---@param start number | nil
---@param stop number | nil
local function decore_as(hl_group, bufnr, row, start, stop)
	start = start or 0
	stop = stop or -1
	vim.api.nvim_buf_add_highlight(bufnr, draft_ns, hl_group, row, start, stop)
end

---@return boolean
local function is_insert_mode()
	return "i" == vim.api.nvim_get_mode().mode
end

--[[
function decorate_row(row)


end]]

local draw_counter = {}

vim.api.nvim_set_decoration_provider(ns, {

	on_line = function(_, winid, bufnr, row)
		local cursor_line = vim.api.nvim_win_get_cursor(winid)[1] - 1

		if cursor_line == row then
			draw_counter[row] = (draw_counter[row] or 0) + 1
			vim.api.nvim_buf_clear_namespace(bufnr, -1, row, row + 1)
			local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
			if is_comment(line) then
				decore_as("NonText", bufnr, row)
			else
				decore_as("Normal", bufnr, row)
				vim.api.nvim_buf_set_extmark(bufnr, ns, row, 0, {
					virt_text = { { "->" .. draw_counter[row] .. " ", "NonText" } },
					virt_text_pos = "inline",
					hl_mode = "combine",
				})

				for s, e in line:gmatch('()"[^"]+"()') do
					decore_as("Statement", bufnr, row, s - 1, e - 1)
				end

				local line_len = #line
				local pos = 1

				while pos <= line_len do
					local s, e = line:find("—", pos, true)
					if not s then
						break
					end

					local next_s, next_e = line:find("—", e + 1, true)
					if next_s then
						decore_as("Statement", bufnr, row, s - 1, next_e)
						pos = next_e + 1
					else
						decore_as("Statement", bufnr, row, s - 1)
						break
					end
				end
				for s, e in line:gmatch('()"[^"]+"()') do
					decore_as("Statement", bufnr, row, s - 1, e - 1)
				end
			end
		end
	end,
})

---@param buf string
---@param tab_length number
function M.render(buf, tab_length)
	vim.api.nvim_buf_clear_namespace(buf, draft_ns, 0, -1)
	-- vim.api.nvim_set_hl(0, "Quote", { italic = true })

	local cursor_pos = vim.fn.line(".")
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

	for nr, line in ipairs(lines) do
		if is_comment(line) then
			decore_as("NonText", buf, nr)
		elseif is_header(line) then
			if nr == cursor_pos and is_insert_mode() then
				make_indent(buf, nr, tab_length)
			else
				make_indent(buf, nr, tab_length * 2)
				decore_as("Title", buf, nr)
			end
		else
			make_indent(buf, nr, tab_length)
			local line_len = #line
			local pos = 1

			while pos <= line_len do
				local s, e = line:find("—", pos, true)
				if not s then
					break
				end

				local next_s, next_e = line:find("—", e + 1, true)
				if next_s then
					decore_as("Statement", buf, nr, s - 1, next_e)
					pos = next_e + 1
				else
					decore_as("Statement", buf, nr, s - 1)
					break
				end
			end
			for s, e in line:gmatch('()"[^"]+"()') do
				decore_as("Statement", buf, nr, s - 1, e - 1)
			end
		end
	end
end

return M
