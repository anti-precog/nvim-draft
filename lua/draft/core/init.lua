local config = require("draft.config").configuration

local active_features = {}

local function set_activate(func)
	table.insert(active_features, func)
end

-- a core features module
---@class CoreModule
local M = {}

-- init module
---@return CoreModule
function M.setup()
	local core_config = config.core
	if core_config.move_by_visual_lines then
		set_activate(require("draft.core.visual_move_keys").vim_setup)
		set_activate(require("draft.core.visual_move_keys").keymaps)
	end
	if core_config.repleace_dash then
		set_activate(require("draft.core.auto_repleace").dash_keymap)
	end
	if core_config.smart_quotes then
		set_activate(require("draft.core.auto_repleace").quotes_keymap)
	end

	local group = vim.api.nvim_create_augroup("draft-core", { clear = true })
	vim.api.nvim_create_autocmd({ "FileType" }, {
		group = group,
		pattern = config.filetypes,
		callback = function()
			for _, feature in ipairs(active_features) do
				feature()
			end
		end,
		desc = "load draft.core improvements",
	})
	return M
end
return M
