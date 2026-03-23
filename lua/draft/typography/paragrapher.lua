local config = require("draft.config").options
local typo = config.typography
local ns = require("draft.config").namespace
local line = require("draft.typography.line")

--local draw_counter = {} -- debug

---@return boolean
local function clear_line()
	vim.api.nvim_buf_clear_namespace(line.buf, ns, line.row, line.row + 1)
	return true
end

---@type table<number, fun()>
local steps = {}
---@type table<number, fun()>
local post_steps = {}

-- a module for decorate lines into paragraphs
---@class paragrapher
local M = {}

-- set current line to decorate
---@param win_id integer
---@param buf_nr integer
---@param row_nr integer
---@param text string
function M.set_line(win_id, buf_nr, row_nr, text)
	line.win = win_id
	line.buf = buf_nr
	line.row = row_nr
	line.text = text
end

-- run all steps
---@param clean boolean
function M.run(clean)
	local start = clean and 1 or 2

	for i = start, #steps do
		local is_next = steps[i]()
		if not is_next then
			return
		end
	end
end

-- run post steps
function M.post_run()
	for i = 1, #post_steps do
		local is_next = post_steps[i]()
		if not is_next then
			return
		end
	end
end

-- init module
function M.setup()
	table.insert(steps, clear_line)
	if typo.comment_hl then
		table.insert(steps, require("draft.typography.hl_comment").try_make)
	end
	if typo.center_asterix then
		table.insert(steps, require("draft.typography.headliner").try_center_asterix)
		table.insert(post_steps, require("draft.typography.headliner").try_recenter_asterix)
	end
	if typo.center_header and typo.header_hl then
		table.insert(steps, require("draft.typography.headliner").try_make_title)
		table.insert(post_steps, require("draft.typography.headliner").try_remake_title)
	elseif typo.center_header then
		table.insert(steps, require("draft.typography.headliner").try_center_header)
		table.insert(post_steps, require("draft.typography.headliner").try_recenter_header)
	elseif typo.header_hl then
		table.insert(steps, require("draft.typography.headliner").try_hl_header)
		table.insert(post_steps, require("draft.typography.headliner").try_rehl_header)
	end
	if typo.indent_size > 0 then
		table.insert(steps, require("draft.typography.indenter").make_indent)
	end
	if typo.quote_hl then
		table.insert(steps, require("draft.typography.hl_quote").make)
	end
	if typo.dialogue_hl then
		table.insert(steps, require("draft.typography.hl_dialogue").make)
	end
	return M
end

return M
