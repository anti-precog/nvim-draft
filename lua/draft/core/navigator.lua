local utils = require("draft.utils")

---@return boolean cursor_status Check if cursor in first row
local function is_on_first_line()
	return utils.get_cursor_line_nr() == 1
end

---@return boolean cursor_status Check if cursor in last row
local function is_on_last_line()
	return utils.get_cursor_line_nr() == utils.get_last_line_nr()
end

---@return boolean cursor_status Check if cursor in last row
local function is_on_first_wrap_line()
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	if cursor_pos[1] ~= 1 then
		return false
	end
	local cursor_screen_pos = vim.fn.screenpos(0, cursor_pos[1], cursor_pos[2] + 1)
	local first_symbol_pos = vim.fn.screenpos(0, 1, 1)

	return cursor_screen_pos.row == first_symbol_pos.row
end

---@return boolean cursor_status Check if cursor in last row
local function is_on_last_wrap_line()
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	local last_line_nr = vim.api.nvim_buf_line_count(0)
	if cursor_pos[1] ~= last_line_nr then
		return false
	end
	local cursor_screen_pos = vim.fn.screenpos(0, last_line_nr, cursor_pos[2] + 1)

	local last_symbol_pos = vim.fn.screenpos(0, last_line_nr, vim.fn.col("$") - 1)
	return cursor_screen_pos.row == last_symbol_pos.row
end

---@return string path_part Name of actual file directory
local function get_dir()
	return vim.fn.expand("%:p:h")
end

---@return string path_part Name of actual file
local function get_filename()
	return vim.fn.expand("%:t")
end

---@param filename string Name of file
---@return number? filename_number Number from filename
local function get_page(filename)
	return tonumber(filename:match("(%d+)"))
end

---@param filename string Name of file
---@param number number Number for filename
local function load_page(filename, number)
	local full_path = get_dir() .. "/" .. filename:gsub("(%d+)", tostring(number), 1)
	vim.cmd("argadd " .. full_path)
	vim.cmd("edit " .. full_path)
end

local function select_page()
	local num = tonumber(vim.fn.input("number: "))
	vim.cmd("redraw!")
	if not num then
		print("Give correct number of file.")
		return
	end
	local filename = get_filename()
	load_page(filename, num)
end

local function turn_page()
	local filename = get_filename()
	local page_num = get_page(filename)
	if not page_num then
		print("No page number")
		return
	end
	load_page(filename, page_num + 1)
end

local function return_page()
	local filename = get_filename()
	local page_num = get_page(filename)
	if not page_num then
		print("No page number")
		return
	elseif page_num == 0 then
		print("You are on zero page")
		return
	end
	load_page(filename, page_num - 1)
end

-- A submodule for files navigations
---@class Navigator
local M = {}

-- Init navigation commmands
function M.commands()
	vim.api.nvim_buf_create_user_command(0, "SelectPage", function()
		select_page()
	end, {
		desc = "Create or open a file with selected number",
	})

	vim.api.nvim_buf_create_user_command(0, "NextPage", function()
		local choice = vim.fn.confirm("Page", "Next", 1)
		if choice == 1 then
			turn_page()
		end
	end, {
		desc = "Go to next page",
	})

	vim.api.nvim_buf_create_user_command(0, "PrevPage", function()
		local choice = vim.fn.confirm("Page", "Prev", 1)
		if choice == 1 then
			return_page()
		end
	end, {
		desc = "Go to prev page",
	})
end

-- Map keys for wrap lines navigator
function M.wrap_lines_keymaps()
	vim.keymap.set("n", "j", function()
		return vim.v.count == 0 and "gj" or "j"
	end, { expr = true, buffer = 0 })

	vim.keymap.set("n", "k", function()
		return vim.v.count == 0 and "gk" or "k"
	end, { expr = true, buffer = 0 })
end

-- Map keys for page navigator
function M.try_turn_page_keymaps()
	vim.keymap.set("n", "j", function()
		if is_on_last_line() then
			return "<cmd>NextPage<CR>"
		end
		return "j"
	end, { expr = true, buffer = 0 })

	vim.keymap.set("n", "k", function()
		if is_on_first_line() then
			return "<cmd>PrevPage<CR>"
		end
		return "k"
	end, { expr = true, buffer = 0 })
end

-- Map keys for full navigation
function M.try_turn_page_wrap_lines_keymaps()
	vim.keymap.set("n", "j", function()
		if is_on_last_wrap_line() then
			return "<cmd>NextPage<CR>"
		end
		return vim.v.count == 0 and "gj" or "j"
	end, { expr = true, buffer = 0 })

	vim.keymap.set("n", "k", function()
		if is_on_first_wrap_line() then
			return "<cmd>PrevPage<CR>"
		end
		return vim.v.count == 0 and "gk" or "k"
	end, { expr = true, buffer = 0 })
end

return M
