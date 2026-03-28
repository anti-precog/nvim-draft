-- A submodule for repleacement nvim keys (j/k) to move on visual not real lines
---@class VisualMoveKeysSubmodule
local M = {}

-- Set vim wrap settings
function M.vim_setup()
	vim.opt_local.wrap = true
	vim.opt_local.linebreak = true
	vim.opt_local.breakindent = true
end

-- Init imporved moves
function M.keymaps()
	vim.keymap.set("n", "j", function()
		return vim.v.count == 0 and "gj" or "j"
	end, { expr = true, buffer = 0 })

	vim.keymap.set("n", "k", function()
		return vim.v.count == 0 and "gk" or "k"
	end, { expr = true, buffer = 0 })
end

return M
