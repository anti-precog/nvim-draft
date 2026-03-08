---@module "navigator"
local M = {}

---@return string
local function get_dir()
	return vim.fn.expand("%:p:h")
end

---@return string
local function get_filename()
	return vim.fn.expand("%:t")
end

---@param filename string
---@return number?
local function get_page(filename)
	return tonumber(filename:match("(%d+)"))
end

---@param filename string
---@param num number
local function load_page(filename, num)
	local full_path = get_dir() .. "/" .. filename:gsub("(%d+)", tostring(num), 1)
	vim.cmd("argadd " .. full_path)
	vim.cmd("edit " .. full_path)
	print("Loaded file: " .. full_path)
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

function M.activate_commands()
	vim.api.nvim_buf_create_user_command(0, "SelectPage", function()
		select_page()
	end, {
		desc = "Create or open a file with selected number",
	})

	vim.api.nvim_buf_create_user_command(0, "NextPage", function()
		turn_page()
	end, {
		desc = "Go to next page",
	})

	vim.api.nvim_buf_create_user_command(0, "PrevPage", function()
		return_page()
	end, {
		desc = "Go to prev page",
	})
end

return M
