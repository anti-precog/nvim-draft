local opt = require("draft.config").options
local config = opt.typography
local ns = require("draft.config").namespace

local line = require("draft.typography.line")

---@return boolean
local is_insert_mode = function()
	return vim.api.nvim_get_mode().mode == "i"
end

---@return boolean
local function is_asterix()
	return line.text:match("^%*+$")
end

---@return boolean
local function is_header()
	return line.text:match("^[A-Z].*[^.]$")
end

local function make_center()
	local win_half = vim.api.nvim_win_get_width(line.win) / 2 - 1
	local line_half = #line.text / 2
	local length = win_half - line_half
	if length <= 0 then
		return
	end
	local space = string.rep(" ", length)
	vim.api.nvim_buf_set_extmark(line.buf, ns, line.row, 0, {
		--virt_text = { { space .. draw_counter[row_nr] .. " ", "NonText" } }, -- debug
		virt_text = { { space, "NonText" } },
		virt_text_pos = "inline",
		hl_mode = "combine",
	})
end

---@return boolean
local function clear_line()
	vim.api.nvim_buf_clear_namespace(line.buf, ns, line.row, line.row + 1)
	return true
end

---@class paragrapher
local M = {}

---@return boolean
function M.try_make_title()
	if is_insert_mode() then
		return true
	end
	if is_header() then
		make_center()
		vim.api.nvim_buf_add_highlight(line.buf, ns, config.header_hl, line.row, 0, #line.text)
		return false
	end
	return true
end

---@return boolean
function M.try_center_header()
	if is_insert_mode() then
		return true
	end
	if is_header() then
		make_center()
		return false
	end
	return true
end

---@return boolean
function M.try_hl_header()
	if is_insert_mode() then
		return true
	end
	if is_header() then
		if config.indent_size > 0 then
			require("draft.typography.indenter").make_indent()
		end

		vim.api.nvim_buf_add_highlight(line.buf, ns, config.header_hl, line.row, 0, #line.text)
		return false
	end
	return true
end

---@return boolean
function M.try_remake_title()
	if is_header() then
		clear_line()
		make_center()
		vim.api.nvim_buf_add_highlight(line.buf, ns, config.header_hl, line.row, 0, #line.text)
		return false
	end
	return true
end

---@return boolean
function M.try_recenter_header()
	if is_header() then
		clear_line()
		make_center()
		return false
	end
	return true
end

---@return boolean
function M.try_rehl_header()
	if is_header() then
		clear_line()

		if config.indent_size > 0 then
			require("draft.typography.indenter").make_indent()
		end

		vim.api.nvim_buf_add_highlight(line.buf, ns, config.header_hl, line.row, 0, #line.text)
		return false
	end
	return true
end

---@return boolean
function M.try_center_asterix()
	if is_insert_mode() then
		return true
	end
	if is_asterix() then
		make_center()
		return false
	end
	return true
end

---@return boolean
function M.try_recenter_asterix()
	if is_asterix() then
		clear_line()
		make_center()
		return false
	end
	return true
end

return M
