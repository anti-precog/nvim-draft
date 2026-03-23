local function check_nvim_version()
	vim.health.start("draft requirements")
	local v = vim.version()
	if v.major == 0 and v.minor >= 10 and v.patch >= 0 then
		vim.health.ok("neovim version >= 0.10.0")
	else
		vim.health.warn("neovim version < 0.10.0")
	end
end

local function is_defined_filetype(ft)
	return vim.tbl_contains(vim.fn.getcompletion("", "filetype"), ft)
end

local options = require("draft.config").options

local function check_hl_groups_config()
	vim.health.start("associated highlight groups")
	local typo = options.typography
	local groups = {
		quotes = typo.quote_hl,
		comments = typo.comment_hl,
		headers = typo.header_hl,
		dialogues = typo.dialogue_hl,
	}

	for section, group in pairs(groups) do -- why not working?
		if vim.fn.hlexists(group) then
			vim.health.ok(group .. " for " .. section)
		else
			vim.health.warn(
				group .. " for " .. section,
				"Define this group in your nvim config or remove from plugin configurtion."
			)
		end
	end
end
local function check_filetypes_config()
	vim.health.start("associated filetypes")
	local filetypes = options.filetypes
	if not next(filetypes) then
		vim.health.error("any filetype associated with plugin", "Fix configuration")
		return
	end
	for _, ft in ipairs(filetypes) do
		if is_defined_filetype(ft) then
			vim.health.ok(ft)
		else
			vim.health.warn(
				ft .. " - no defined",
				"Define this type in your nvim config or remove from plugin configurtion."
			)
		end
	end
end

local function check_status(name)
	if package.loaded[name] then
		vim.health.info(name)
	end
end

local M = {}
M.check = function()
	check_nvim_version()
	check_filetypes_config()
	check_hl_groups_config()
end
return M
