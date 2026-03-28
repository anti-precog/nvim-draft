---@type CoreConfig
local core_config = require("draft.config").configuration.core

local active_features = {}

---@param feature fun() Add feature to activate
local function set_activate(feature)
	table.insert(active_features, feature)
end

-- a core features module
---@class CoreModule
local M = {}

-- Init module
---@return CoreModule
function M.setup()
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
		pattern = "draft",
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
