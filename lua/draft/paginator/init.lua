local config = require("draft.config").configuration

-- a module for quickly jumping through files in the project
---@class PaginatorModule
local M = {}

---@return PaginatorModule
function M.setup()
	local group = vim.api.nvim_create_augroup("draft-nav", { clear = true })

	vim.api.nvim_create_autocmd({ "FileType" }, {
		group = group,
		pattern = config.filetypes,
		callback = function()
			require("draft.paginator.file_jumping").commands()
		end,
		desc = "activate drafts navigator",
	})
	return M
end

return M
