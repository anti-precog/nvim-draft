local config = require("draft.config").options

-- a basic features module
---@class core
local M = {}

-- init module
---@param opts options|nil
---@return core
function M.setup(opts)
	if opts then
		config = require("draft.config").setup(opts).options
	end

	local features = {}
	if config.move_by_visual_lines then
		table.insert(features, require("draft.core.visual_move_keys").setup)
	end
	if config.auto_repleace_symbols then
		local auto_repleace = require("draft.core.auto_repleace")
		if config.auto_repleace_symbols.dash then
			table.insert(features, auto_repleace.set_dash_key)
		end
		if config.auto_repleace_symbols.smart_quotes then
			table.insert(features, auto_repleace.set_smart_quotes)
		end
	end

	local group = vim.api.nvim_create_augroup("draft-core", { clear = true })
	vim.api.nvim_create_autocmd({ "FileType" }, {
		group = group,
		pattern = config.filetypes,
		callback = function()
			for _, func in ipairs(features) do
				func()
			end
		end,
		desc = "load draft.core settings",
	})
	return M
end
return M
