---@module "core"
local M = {}

function M.setup()
	vim.opt_local.tabstop = 8
	vim.opt_local.shiftwidth = 8
	vim.opt_local.wrap = true
	vim.opt_local.breakindent = true
end

function M.set_visual_move()
	vim.keymap.set("n", "j", function()
		return vim.v.count == 0 and "gj" or "j"
	end, { expr = true, buffer = 0 })

	vim.keymap.set("n", "k", function()
		return vim.v.count == 0 and "gk" or "k"
	end, { expr = true, buffer = 0 })

	vim.keymap.set("i", "-", "—", { buffer = true })
	vim.keymap.set("i", "=", "–", { buffer = true })
end

return M
