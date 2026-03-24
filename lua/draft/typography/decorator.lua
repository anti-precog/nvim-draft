local config = require("draft.config").configuration
local ns = require("draft.config").namespace
local selected_line = require("draft.typography.line")

--local draw_counter = {} -- debug

---@type table<number, fun()>
local steps = {}
---@type table<number, fun()>
local post_steps = {}

local function add_step(func)
	table.insert(steps, func)
end

local function add_post_CR_step(func)
	table.insert(post_steps, func)
end

---@return boolean
local function clear_line()
	vim.api.nvim_buf_clear_namespace(selected_line.buf, ns, selected_line.row, selected_line.row + 1)
	return true
end
-- a module for decorate lines into paragraphs
---@class Decorator
local M = {}

-- set current line to decorate
---@param win_id integer
---@param buf_nr integer
---@param row_nr integer
---@param text string
function M.set_line(win_id, buf_nr, row_nr, text)
	selected_line.win = win_id
	selected_line.buf = buf_nr
	selected_line.row = row_nr
	selected_line.text = text
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
	local typo_config = config.typography
	table.insert(steps, clear_line)
	if typo_config.comment_hl then
		add_step(require("draft.typography.sub.hl_comment").try_make)
	end
	if typo_config.center_asterix then
		add_step(require("draft.typography.sub.headliner").try_center_asterix)
		add_post_CR_step(require("draft.typography.sub.headliner").try_recenter_asterix)
	end
	if typo_config.center_header and typo_config.header_hl then
		add_step(require("draft.typography.sub.headliner").try_make_title)
		add_step(require("draft.typography.sub.headliner").try_remake_title)
	elseif typo_config.center_header then
		add_step(require("draft.typography.sub.headliner").try_center_header)
		add_post_CR_step(require("draft.typography.sub.headliner").try_recenter_header)
	elseif typo_config.header_hl then
		add_step(require("draft.typography.sub.headliner").try_hl_header)
		add_post_CR_step(require("draft.typography.sub.headliner").try_rehl_header)
	end
	if typo_config.indent_size > 0 then
		add_step(require("draft.typography.sub.indenter").make_indent)
	end
	if typo_config.quote_hl then
		add_step(require("draft.typography.sub.hl_quote").make)
	end
	if typo_config.dialogue_hl then
		add_step(require("draft.typography.sub.hl_dialogue").make)
	end
	return M
end

return M
