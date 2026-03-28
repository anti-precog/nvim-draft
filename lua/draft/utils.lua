---@class Utils
local M = {}

-- Check nvim INSERT mode status
---@return boolean is_insert_mode Status of current vim INSERT mode
function M.is_insert_mode()
	return vim.api.nvim_get_mode().mode == "i"
end

return M
