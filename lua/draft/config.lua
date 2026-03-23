-- plugin options for each module
---@class options
---@field filetypes string[]
---@field dash_symbol string
---@field paginator boolean
---@field improvements table
---@field typography table
local defaults = {
	-- all loaded features works only fot that filetypes
	filetypes = {
		"draft",
		"text",
	},

	-- select how to recognize dialogues as em-dash or en-dash
	dash_symbol = "em-dash",

	-- [[ CORE module options ]]
	core = {
		move_by_visual_lines = true,
		smart_quotes = true,
		repleace_dash = "--",
	},

	-- [[ TYPOGRAPHY module options ]]
	typography = {
		indent_size = 2,
		center_header = true,
		center_asterix = true,
		dialogue_hl = "Statement",
		quote_hl = "Statement",
		comment_hl = "NonText",
		header_hl = "Title",
	},

	-- [[ PAGINATOR module options ]]
	paginator = false,
}

---@class config
local M = {}

---@type options
M.options = defaults

---@type number
M.namespace = vim.api.nvim_create_namespace("draft")

---@param opts options
---@return config
function M.setup(opts)
	opts = opts or {}

	vim.validate({
		filetypes = { opts.filetypes, "table", true },
		dash_symbol = {
			opts.dash_symbol,
			function(v)
				return type(v) == "string" and (v == "em-dash" or v == "en-dash")
			end,
			true,
		},
		core = { opts.core, { "table, boolean" }, true },
		typography = { opts.typography, { "table", "boolean" }, true },
		paginator = { opts.paginator, "boolean", true },
	})

	M.options = vim.tbl_deep_extend("force", defaults, opts)

	if type(M.options.core) == "table" then
		vim.validate({
			move_by_visual_lines = { M.options.core.move_by_visual_lines, "boolean", false },
			smart_quotes = { M.options.core.smart_quotes, "boolean", false },
			repleace_dash = { M.options.core.repleace_dash, { "string", "boolean" }, false },
		})
	end

	if type(M.options.typography) == "table" then
		vim.validate({
			indent_size = { M.options.typography.indent_size, "number", false },
			center_header = { M.options.typography.center_header, "boolean", false },
			center_asterix = { M.options.typography.center_asterix, "boolean", false },
			dialogue_hl = { M.options.typography.dialogue_hl, { "string", "boolean" }, false },
			quote_hl = { M.options.typography.quote_hl, { "string", "boolean" }, false },
			comment_hl = { M.options.typography.comment_hl, { "string", "boolean" }, false },
			header_hl = { M.options.typography.header_hl, { "string", "boolean" }, false },
		})
	end

	if M.options.dash_symbol == "em-dash" then
		M.options.dash_symbol = "—"
	elseif M.options.dash_symbol == "en-dash" then
		M.options.dash_symbol = "–"
	end
	return M
end

return M
