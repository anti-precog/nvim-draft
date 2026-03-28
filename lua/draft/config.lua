---@class Config
---@field dash_symbol string
---@field paginator boolean
---@field improvements table
---@field typography table
local defaults = {
	-- select how to recognize dialogues as em-dash or en-dash
	dash_symbol = "em-dash",

	-- Configuration for core module
	---@class CoreConfig
	core = {
		move_by_visual_lines = true,
		smart_quotes = true,
		repleace_dash = "--",
	},

	-- Configuration for typography module
	---@class TypographyConfig
	typography = {
		indent_size = 4,
		center_header = false,
		center_asterix = true,
		dialogue_hl = "Statement",
		quote_hl = "Statement",
		comment_hl = "NonText",
		header_hl = "Title",
	},

	-- Configuration for paginator module
	paginator = false,
}

local function pre_validate(opts)
	vim.validate({
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
end

---@class ConfigModule
local M = {}

---@type Config
M.configuration = defaults

local function post_validate()
	if type(M.configuration.core) == "table" then
		vim.validate({
			move_by_visual_lines = { M.configuration.core.move_by_visual_lines, "boolean", false },
			smart_quotes = { M.configuration.core.smart_quotes, "boolean", false },
			repleace_dash = { M.configuration.core.repleace_dash, { "string", "boolean" }, false },
		})
	end

	if type(M.configuration.typography) == "table" then
		vim.validate({
			indent_size = { M.configuration.typography.indent_size, "number", false },
			center_header = { M.configuration.typography.center_header, "boolean", false },
			center_asterix = { M.configuration.typography.center_asterix, "boolean", false },
			dialogue_hl = { M.configuration.typography.dialogue_hl, { "string", "boolean" }, false },
			quote_hl = { M.configuration.typography.quote_hl, { "string", "boolean" }, false },
			comment_hl = { M.configuration.typography.comment_hl, { "string", "boolean" }, false },
			header_hl = { M.configuration.typography.header_hl, { "string", "boolean" }, false },
		})
	end
end

local function concat_with_defaults(opts)
	M.configuration = vim.tbl_deep_extend("force", defaults, opts)
end

local function repleace_dash()
	if M.configuration.dash_symbol == "em-dash" then
		M.configuration.dash_symbol = "—"
	elseif M.configuration.dash_symbol == "en-dash" then
		M.configuration.dash_symbol = "–"
	end
end

---@type integer Global plugin namespace
M.namespace = vim.api.nvim_create_namespace("draft")

-- Init custom configuration
---@param opts Config
---@return ConfigModule
function M.setup(opts)
	opts = opts or {}

	pre_validate(opts)
	concat_with_defaults(opts)
	post_validate()
	repleace_dash()

	return M
end

return M
