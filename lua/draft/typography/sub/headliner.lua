local opt = require("draft.config").configuration
local typo_config = opt.typography
local ns = require("draft.config").namespace

local selected_line = require("draft.typography.line")

---@return boolean
local is_insert_mode = function()
	return vim.api.nvim_get_mode().mode == "i"
end

---@return boolean
local function is_asterix()
	return selected_line.text:match("^%*+$")
end

---@return boolean
local function is_header()
	return selected_line.text:match("^[A-Z].*[^.]$")
end

local function make_center()
	local win_half = vim.api.nvim_win_get_width(selected_line.win) / 2 - 1
	local line_half = #selected_line.text / 2
	local length = win_half - line_half
	if length <= 0 then
		return
	end
	local space = string.rep(" ", length)
	vim.api.nvim_buf_set_extmark(selected_line.buf, ns, selected_line.row, 0, {
		--virt_text = { { space .. draw_counter[row_nr] .. " ", "NonText" } }, -- debug
		virt_text = { { space, "NonText" } },
		virt_text_pos = "inline",
		hl_mode = "combine",
	})
end

---@return boolean
local function clear_line()
	vim.api.nvim_buf_clear_namespace(selected_line.buf, ns, selected_line.row, selected_line.row + 1)
	return true
end

---@class HeadlinerSubmodule
local M = {}

---@return boolean
function M.try_make_title()
	if is_insert_mode() then
		return true
	end
	if is_header() then
		make_center()
		vim.api.nvim_buf_add_highlight(
			selected_line.buf,
			ns,
			typo_config.header_hl,
			selected_line.row,
			0,
			#selected_line.text
		)
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
		if typo_config.indent_size > 0 then
			require("draft.typography.sub.indenter").make_indent()
		end

		vim.api.nvim_buf_add_highlight(
			selected_line.buf,
			ns,
			typo_config.header_hl,
			selected_line.row,
			0,
			#selected_line.text
		)
		return false
	end
	return true
end

---@return boolean
function M.try_remake_title()
	if is_header() then
		clear_line()
		make_center()
		vim.api.nvim_buf_add_highlight(
			selected_line.buf,
			ns,
			typo_config.header_hl,
			selected_line.row,
			0,
			#selected_line.text
		)
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

		if typo_config.indent_size > 0 then
			require("draft.typography.indenter").make_indent()
		end

		vim.api.nvim_buf_add_highlight(
			selected_line.buf,
			ns,
			typo_config.header_hl,
			selected_line.row,
			0,
			#selected_line.text
		)
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
