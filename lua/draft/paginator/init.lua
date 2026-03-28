-- A module for quickly jumping through files in the project
---@class PaginatorModule
local M = {}

-- Init module
---@return PaginatorModule
function M.setup()
	local group = vim.api.nvim_create_augroup("draft-nav", { clear = true })

	vim.api.nvim_create_autocmd({ "FileType" }, {
		group = group,
		pattern = "draft",
		callback = function()
			require("draft.paginator.file_jumping").commands()
		end,
		desc = "activate drafts navigator",
	})
	return M
end

return M
