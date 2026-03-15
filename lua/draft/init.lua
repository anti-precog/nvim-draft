---@module "draft"
local M = {}

---@param opts table
function M.setup(opts)
	local draft_gr = vim.api.nvim_create_augroup("draft", { clear = true })
	opts = opts or {}

	local core = require("draft.core")
	vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
		group = draft_gr,
		-- NOTE: *.draft -> (BufEnter) draft -> (FileType)
		pattern = { "draft", "*.draft" },
		callback = function()
			core.set_dash_keys()
			core.set_visual_move_keys()
		end,
		desc = "load draft.core settings",
	})

	local nav = require("draft.navigator")
	vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
		group = draft_gr,
		-- NOTE: *.draft -> (BufEnter) draft -> (FileType)
		pattern = { "draft", "*.draft" },
		callback = function()
			nav.activate_commands()
		end,
		desc = "activate drafts navigator",
	})

	local decorator = require("draft.decorator")

	vim.api.nvim_create_autocmd({ "BufEnter" }, {
		group = draft_gr,
		-- NOTE: *.draft -> (BufEnter)
		pattern = { "*.draft" },
		callback = function()
			vim.cmd("redraw")
		end,
		desc = "activate drafts navigator",
	})
end

return M
