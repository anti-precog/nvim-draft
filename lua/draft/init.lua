---@module "draft"
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

---@param opts table
function M.setup(opts)
	opts = opts or {}
	--[[ HACK:
	vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
		pattern = "*.draft",
		callback = function()
			vim.bo.filetype = "draft"
			print("Filetype set to draft")
		end,
	})
	]]
	--

	local nav = require("draft.navigation")
	local decorator = require("draft.decorator")

	-- control indent in lines
	-- PERF: Select only necessary events for autocmd
	vim.api.nvim_create_autocmd(
		{ "FileType", "BufEnter", "BufWinEnter", "TextChanged", "TextChangedI", "InsertLeave" },
		{
			group = draft_gr,
			pattern = "*.draft",
			callback = function(args)
				decorator.render(args.buf)
			end,
			desc = "Redraw indents",
		}
	)

	vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "BufLeave" }, {
		group = draft_gr,
		pattern = { "draft", "*.draft" },
		callback = function()
			print("jestem w " .. vim.bo.filetype)
			setup_local_options()
			setup_keymap()
			nav.activate_commands()
		end,
		desc = "Load draw settings",
	})

	vim.api.nvim_create_autocmd("ColorScheme", {
		group = draft_gr,
		callback = function(args)
			decorator.render(args.buf)
		end,
		desc = "Add special highlight for quotes",
	})
end

return M
