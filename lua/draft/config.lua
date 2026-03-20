local validator = require("draft.validator")

-- plugin options for each module
---@class options
---@field filetypes string[]
---@field dash string
---@field move_by_visual_lines boolean
---@field auto_repleace_symbols table<string, string|boolean>|nil
---@field paginator boolean
---@field indent number
---@field syntax table<string, string>|nil
---@field center table<string, boolean>|nil
local defaults = {
	-- all loaded features works only fot that filetypes
	filetypes = { "draft" },

	-- select how to recognize dialogues as em-dash or en-dash
	dash = "—",

	-- [[ CORE module options ]]
	-- improved moved on features
	-- true - navigating [j/k] through the file ignore line wraping
	-- false - disable that feature
	move_by_visual_lines = true,

	-- emdahs(—) and dash(–) can be auto replace by selected phraze
	-- it can be symbol one even characters string
	-- nil - disable that repleacment
	auto_repleace_symbols = {
		dash = "--", -- used to mark dialogues
		smart_quotes = '"', -- curly quotes („”)
		-- TODO: external custom signs
	},

	-- [[ PAGINATOR module options ]]
	-- load paginator feature
	paginator = false,

	-- [[ DECORATOR module options ]]
	-- set indent size for all paragraph
	indent = 2, -- set to 0 to disable

	-- use accessible highlight-groups to syntax specific section
	-- nil - disable syntax
	syntax = {
		dialogue = "Quotes",
		quote = "Quotes",
		comment = "NonText",
		header = "Title",
	},

	-- center selected sections
	-- nil - leave default indent
	center = {
		header = false,
		asterix = true,
	},
}

---@class config
local M = {}

---@type number
M.namespace = vim.api.nvim_create_namespace("draft")

---@type options
M.options = nil

---@class moduleChecker
---@field core boolean
---@field paginator boolean
---@field decorator boolean
M.valid = {
	core = false,
	paginator = false,
	decorator = false,
}

---@param opts options
---@return config
function M.setup(opts)
	M.options = vim.tbl_deep_extend("force", defaults, opts or {})

	if M.options.move_by_visual_lines == true or validator.has_values(M.options.auto_repleace_symbols) then
		M.valid.core = true
	end

	if M.options.paginator == true then
		M.valid.paginator = true
	end

	if
		validator.is_positive(M.options.indent)
		or validator.has_values(M.options.syntax)
		or validator.has_values(M.options.center)
	then
		M.valid.decorator = true
	end

	return M
end

return M
