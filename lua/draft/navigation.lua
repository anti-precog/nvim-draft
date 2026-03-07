local M = {}

local function get_number()
	local filename = vim.fn.expand("%:t") -- np. "23-scene.draft"
	local num = filename:match("(%d+)") -- "23" as string
	num = tonumber(num) -- convert to number
	return num
end

local function go_to_page(num)
	local current_file = vim.fn.expand("%:t")
	local current_dir = vim.fn.expand("%:p:h")

	local target_file = current_file:gsub("(%d+)", tostring(num), 1)
	local full_path = current_dir .. "/" .. target_file

	vim.cmd("argadd " .. full_path)
	vim.cmd("edit " .. full_path)

	print("Loaded file: " .. target_file)
end

vim.api.nvim_create_user_command("SelectPage", function()
	-- local num = tonumber(opts.args)
	local num = vim.fn.input("number: ")
	if not num then
		print("Give correct number of file.")
		return
	end
	vim.cmd("redraw!")
	go_to_page(num)
end, {
	desc = "Create or open a file with selected number",
})

vim.api.nvim_create_user_command("NextPage", function()
	page_num = get_number()
	if not page_num then
		print("No page number")
		return
	end
	go_to_page(page_num + 1)
end, {
	desc = "Go to next page",
})

vim.api.nvim_create_user_command("PrevPage", function()
	page_num = get_number()
	if not page_num then
		print("No page number")
		return
	elseif page_num == 0 then
		print("You are on zero page")
		return
	end
	go_to_page(page_num - 1)
end, {
	desc = "Go to prev page",
})

return M
