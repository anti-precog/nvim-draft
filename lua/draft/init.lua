---@module "draft"
local M = {}

---@param opts table
function M.setup(opts)
	local draft_gr = vim.api.nvim_create_augroup("draft", { clear = true })
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

	local core = require("draft.core")
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
			core.setup()
			core.set_visual_move()
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
