---@module "decorator"
local M = {}

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
	return line:match("^\t.*")
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
local function decore_as(hl_group, buf, line_nr, start, stop)
	start = start or 0
	stop = stop or -1
	vim.api.nvim_buf_add_highlight(buf, draft_ns, hl_group, line_nr - 1, start, stop)
end

---@param buf string
function M.render(buf)
	vim.api.nvim_buf_clear_namespace(buf, draft_ns, 0, -1)
	-- vim.api.nvim_set_hl(0, "Quote", { italic = true })

	local cursor_pos = vim.fn.line(".")
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

	for nr, line in ipairs(lines) do
		if is_comment(line) then
			decore_as("NonText", buf, nr)
		elseif is_header(line) then
			if nr ~= cursor_pos then
				make_indent(buf, nr, 10)
				decore_as("Title", buf, nr)
			else
				make_indent(buf, nr, 5)
			end
		else
			make_indent(buf, nr, 5)

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
