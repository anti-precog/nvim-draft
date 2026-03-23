local config = require("draft.config").options
local core = config.core

-- a core features module
---@class core
local M = {}

-- init module
---@return core
function M.setup()
	local active_features = {}
	if core.move_by_visual_lines then
		table.insert(active_features, require("draft.core.visual_move_keys").setup)
	end
	if core.repleace_dash then
		table.insert(active_features, require("draft.core.auto_repleace").set_dash_key)
	end
	if core.smart_quotes then
		table.insert(active_features, require("draft.core.auto_repleace").set_smart_quotes)
	end

	local group = vim.api.nvim_create_augroup("draft-core", { clear = true })
	vim.api.nvim_create_autocmd({ "FileType" }, {
		group = group,
		pattern = config.filetypes,
		callback = function()
			for _, func in ipairs(active_features) do
				func()
			end
		end,
		desc = "load draft.core improvements",
	})
	return M
end
return M
