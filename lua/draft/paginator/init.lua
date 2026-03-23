local opt = require("draft.config").options

-- a module for quickly jumping through files in the project
---@class paginator
local M = {}

-- init module
---@return paginator
function M.setup()
	local group = vim.api.nvim_create_augroup("draft-nav", { clear = true })

	vim.api.nvim_create_autocmd({ "FileType" }, {
		group = group,
		pattern = opt.filetypes,
		callback = function()
			require("draft.paginator.commands").setup()
		end,
		desc = "activate drafts navigator",
	})
	return M
end

return M
