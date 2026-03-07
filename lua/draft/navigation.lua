local M = {}

local function get_dir()
	return vim.fn.expand("%:p:h")
end

local function get_filename()
	return vim.fn.expand("%:t")
end

local function get_page(filename)
	return tonumber(filename:match("(%d+)"))
end

local function open_page(filename, num)
	local full_path = get_dir() .. "/" .. filename:gsub("(%d+)", tostring(num), 1)
	vim.cmd("argadd " .. full_path)
	vim.cmd("edit " .. full_path)
	print("Loaded file: " .. full_path)
end

vim.api.nvim_create_user_command("SelectPage", function()
	local num = tonumber(vim.fn.input("number: "))
	vim.cmd("redraw!")
	if not num then
		print("Give correct number of file.")
		return
	end
	filename = get_filename()
	open_page(filename, num)
end, {
	desc = "Create or open a file with selected number",
})

vim.api.nvim_create_user_command("NextPage", function()
	filename = get_filename()
	page_num = get_page(filename)
	if not page_num then
		print("No page number")
		return
	end
	open_page(filename, page_num + 1)
end, {
	desc = "Go to next page",
})

vim.api.nvim_create_user_command("PrevPage", function()
	filename = get_filename()
	page_num = get_page(filename)
	if not page_num then
		print("No page number")
		return
	elseif page_num == 0 then
		print("You are on zero page")
		return
	end
	open_page(filename, page_num - 1)
end, {
	desc = "Go to prev page",
})

return M
