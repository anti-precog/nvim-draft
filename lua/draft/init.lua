local M = {}

local function setup_local_options()
	vim.opt_local.tabstop = 8
	vim.opt_local.shiftwidth = 8
	vim.opt_local.wrap = true
	vim.opt_local.breakindent = true
end

local function setup_keymap()
	-- moves along "visual" lines, no on real ones
	vim.keymap.set("n", "j", function()
		return vim.v.count == 0 and "gj" or "j"
	end, { expr = true })
	vim.keymap.set("n", "k", function()
		return vim.v.count == 0 and "gk" or "k"
	end, { expr = true })

	vim.keymap.set("i", "-", "—", { buffer = true })
	vim.keymap.set("i", "=", "–", { buffer = true })
end

local draft_gr = vim.api.nvim_create_augroup("draft", { clear = true })

local hl = require("draft.highlight")

function M.setup(opts)
	opts = opts or {}

	local nav = require("draft.navigation")
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
			hl.update_syntax()
		end,
		desc = "Load draw settings",
	})

	vim.api.nvim_create_autocmd("ColorScheme", {
		group = draft_gr,
		callback = function()
			if vim.bo.filetype == "draft" then
				hl.update_syntax()
			end
		end,
		desc = "Add special highlight for quotes",
	})
end

return M
