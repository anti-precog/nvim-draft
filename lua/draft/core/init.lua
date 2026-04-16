local core_config = require("draft.config").configuration.core
local ts_config = require("draft.config").configuration.treesitter_integration

local active_features = {}

---@param feature fun() Add feature to activate
local function set_activate(feature)
	table.insert(active_features, feature)
end

local function vim_setup()
	vim.opt_local.wrap = true
	vim.opt_local.linebreak = true
	vim.opt_local.breakindent = true
end

---@return boolean config_status Check if auto_turn_page is active
local function is_page_navigator()
	return core_config.auto_turn_page
end

---@return boolean config_status Check if move_by_visual_lines is active
local function is_wrap_navigator()
	return core_config.move_by_visual_lines
end

---@return boolean config_status Check if all navigator features are active
local function is_full_navigator()
	return is_page_navigator() and is_wrap_navigator()
end

-- A core features module
---@class CoreModule
local M = {}

-- Init module
---@return CoreModule
function M.setup()
	set_activate(vim_setup)

	if core_config.repleace_dash then
		set_activate(require("draft.core.auto_repleace").dash_keymap)
	end
	if core_config.repleace_ellipsis then
		set_activate(require("draft.core.auto_repleace").ellipsis_keymap)
	end
	if core_config.smart_quotes then
		set_activate(require("draft.core.auto_repleace").quotes_keymap)
	end
	if is_full_navigator() then
		local nav = require("draft.core.navigator")
		set_activate(nav.commands)
		set_activate(nav.try_turn_page_wrap_lines_keymaps)
	elseif is_wrap_navigator() then
		local nav = require("draft.core.navigator")
		set_activate(nav.wrap_lines_keymaps)
	elseif is_page_navigator() then
		local nav = require("draft.core.navigator")
		set_activate(nav.commands)
		set_activate(nav.try_turn_page_keymaps)
	end

	local group = vim.api.nvim_create_augroup("draft-core", { clear = true })
	vim.api.nvim_create_autocmd({ "FileType" }, {
		group = group,
		pattern = "draft",
		callback = function()
			for _, feature in ipairs(active_features) do
				feature()
			end

			if ts_config and ts_config.skip_meta_lines then
				local skipper = require("draft.core.ts.skipper")
				vim.api.nvim_create_autocmd({ "CursorMoved" }, {
					group = group,
					callback = function()
						skipper.try_skip()
					end,
					desc = "load draft.core skipper",
				})
			end
		end,
		desc = "load draft.core improvements",
	})
	return M
end
return M
