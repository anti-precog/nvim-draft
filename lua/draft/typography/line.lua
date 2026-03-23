-- Current decorated line
-- win and buf point where line is in nvim
-- number of row point it in document
---@class line
---@field win integer|nil	refers to nvim window id
---@field buf integer|nil	refers to nvim buffer id
---@field row integer|nil	number of row
---@field text string|nil	value of line
local line = {}

line.win = nil
line.buf = nil
line.row = nil
line.text = nil

return line
