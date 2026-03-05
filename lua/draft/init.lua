local M = {}

local function setup_local_options()
	vim.opt_local.tabstop = 8
	vim.opt_local.shiftwidth = 8
	vim.opt_local.wrap = true
	vim.opt_local.breakindent = true
end

local config = require("draft.commands")

local function setup_keymap()
	vim.keymap.set("i", "-", "—", { buffer = true })
	vim.keymap.set("i", "=", "–", { buffer = true })
	vim.api.nvim_set_keymap("n", "N", ":NextPage<CR>", { noremap = true, silent = true }) -- następny
	vim.api.nvim_set_keymap("n", "P", ":PrevPage<CR>", { noremap = true, silent = true }) -- poprzedni
	vim.api.nvim_set_keymap(
		"n",
		"S",
		':lua GoToFileNumber(tonumber(vim.fn.input("Numer pliku: ")))<CR>',
		{ noremap = true, silent = true }
	)
end

local draft_gr = vim.api.nvim_create_augroup("draft", { clear = true })

local hl = require("draft.highlight")

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
				hl.update_indent(args.buf)
			end,
			desc = "Redraw indents",
		}
	)

	vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "WinEnter" }, {
		group = draft_gr,
		pattern = { "draft", "*.draft" },
		callback = function()
			setup_local_options()
			setup_keymap()
			hl.setup()
			hl.update_quote()
		end,
		desc = "Load draw settings",
	})

	vim.api.nvim_create_autocmd("ColorScheme", {
		group = draft_gr,
		callback = function()
			if vim.bo.filetype == "draft" then
				hl.update_quote()
			end
		end,
		desc = "Add special highlight for quotes",
	})
end

return M
