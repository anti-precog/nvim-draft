local M = {}

local draft_ns = vim.api.nvim_create_namespace("draft")
local draft_gr = vim.api.nvim_create_augroup("draft", { clear = true })

local function update_indent(buf)
	-- PERF: Set only for viusal lines
	vim.api.nvim_buf_clear_namespace(buf, draft_ns, 0, -1)
	for i = 0, vim.api.nvim_buf_line_count(buf) - 1 do
		vim.api.nvim_buf_set_extmark(buf, draft_ns, i, 0, {
			virt_text = { { "  ", "NonText" } },
			virt_text_pos = "inline",
			hl_mode = "combine",
		})
	end
	print("update indent")
end

function NewFileNumber(direction)
	direction = direction or 1
	local current_file = vim.fn.expand("%:t")
	local current_dir = vim.fn.expand("%:p:h")

	if current_file == "" then
		print("Nie ma aktualnego pliku!")
		return
	end

	local new_file = current_file:gsub("(%d+)", function(n)
		local new_num = tonumber(n) + direction
		if new_num < 0 then
			new_num = 0
		end
		return tostring(new_num)
	end, 1)

	local full_path = current_dir .. "/" .. new_file

	vim.cmd("argadd " .. full_path)
	vim.cmd("edit " .. full_path)

	print("Utworzono / przeszedł do pliku: " .. full_path)
end

function GoToFileNumber(num)
	if not num then
		print("Podaj numer pliku!")
		return
	end

	local current_file = vim.fn.expand("%:t")
	local current_dir = vim.fn.expand("%:p:h")

	if current_file == "" then
		print("Nie ma aktualnego pliku!")
		return
	end

	local target_file = current_file:gsub("(%d+)", tostring(num), 1)
	local full_path = current_dir .. "/" .. target_file

	vim.cmd("argadd " .. full_path)
	vim.cmd("edit " .. full_path)

	print("Przeszedł do pliku: " .. full_path)
end

local function setup_vim()
	vim.opt_local.tabstop = 8
	vim.opt_local.shiftwidth = 8
	vim.opt_local.wrap = true
	vim.opt_local.breakindent = true
	print("setup basic vim")
end

local function setup_keymap()
	vim.keymap.set("i", "-", "—", { buffer = true })
	vim.keymap.set("i", "=", "–", { buffer = true })
	vim.api.nvim_set_keymap("n", "N", ":lua NewFileNumber(1)<CR>", { noremap = true, silent = true }) -- następny
	vim.api.nvim_set_keymap("n", "P", ":lua NewFileNumber(-1)<CR>", { noremap = true, silent = true }) -- poprzedni
	vim.api.nvim_set_keymap(
		"n",
		"S",
		':lua GoToFileNumber(tonumber(vim.fn.input("Numer pliku: ")))<CR>',
		{ noremap = true, silent = true }
	)
	print("setup keymap")
end

local function load_syntax()
	local this_file = debug.getinfo(1, "S").source:sub(2)
	local this_dir = this_file:match("(.*/)")
	local syntax_file = this_dir .. "syntax.vim"
	vim.cmd("source " .. syntax_file)
	print("load syntax " .. syntax_file)
end

function M.setup(opts)
	opts = opts or {}

	-- control indent in lines
	-- PERF: Select only necessary events for autocmd

	vim.api.nvim_create_autocmd(
		{ "FileType", "BufEnter", "BufWinEnter", "TextChanged", "TextChangedI", "InsertLeave" },
		{
			group = draft_gr,
			pattern = "*.draft",
			callback = function(args)
				update_indent(args.buf)
			end,
		}
	)

	vim.api.nvim_create_autocmd("BufEnter", {
		group = draft_gr,
		pattern = "*.draft",
		callback = function()
			setup_vim()
			setup_keymap()
			load_syntax()
		end,
	})
end

return M
