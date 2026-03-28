---@alias NextStep boolean Continue or break next step

local global = require("draft.config")
local selected_line = require("draft.typography.line")

---@type table<number, fun()> All implemented decoration steps
local decoration_steps = {}

---@type table<number, fun()> Post decoratipn steps
local post_decoration_steps = {}

---@param func fun() Next action to do in ordered decoration steps
local function add_step(func)
	table.insert(decoration_steps, func)
end

---@param func fun() Next action to do in post decoration proces
local function add_post_CR_step(func)
	table.insert(post_decoration_steps, func)
end

---@return NextStep next_step Allways return true
local function clear_decoration_for_selected_line()
	-- HACK: duplicated funciton
	vim.api.nvim_buf_clear_namespace(
		selected_line.buf_id,
		global.namespace,
		selected_line.row_id,
		selected_line.row_id + 1
	)
	return true
end

-- Decorate lines into paragraphs
---@class Decorator
local M = {}

-- Set current line to decorate
---@param win_id integer Current decorated window id
---@param buf_id integer Current decorated buffer id
---@param row_id integer Current decorated row id
---@param text string Current decorated text
function M.set_line(win_id, buf_id, row_id, text)
	selected_line.win_id = win_id
	selected_line.buf_id = buf_id
	selected_line.row_id = row_id
	selected_line.text = text
end

-- Run all decoration steps in order
---@param clean boolean Clean line before decorate
function M.run(clean)
	local first_step_id = clean and 1 or 2

	for id = first_step_id, #decoration_steps do
		if not decoration_steps[id]() then
			return
		end
	end
end

-- Run post decoration steps in order
function M.post_run()
	for id = 1, #post_decoration_steps do
		if not post_decoration_steps[id]() then
			return
		end
	end
end

-- Init decorator
---@return Decorator
function M.init()
	---@type TypographyConfig
	local typo_config = require("draft.config").configuration.typography

	add_step(clear_decoration_for_selected_line)
	if typo_config.comment_hl then
		add_step(require("draft.typography.sub.hl_comment").try_highlight)
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
		add_step(require("draft.typography.sub.hl_quote").highlight)
	end
	if typo_config.dialogue_hl then
		add_step(require("draft.typography.sub.hl_dialogue").highlight)
	end
	return M
end

return M
