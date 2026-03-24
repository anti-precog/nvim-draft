local function check_nvim_version()
	vim.health.start("draft requirements")
	local v = vim.version()
	if v.major == 0 and v.minor >= 10 and v.patch >= 0 then
		vim.health.ok("neovim version >= 0.10.0")
	else
		vim.health.warn("neovim version < 0.10.0")
	end
end

local function is_defined_filetype(filetype)
	return vim.tbl_contains(vim.fn.getcompletion("", "filetype"), filetype)
end

local config = require("draft.config").configuration

local function check_hl_groups_config()
	vim.health.start("associated highlight groups")
	local typo_config = config.typography
	local hl_groups = {
		quotes = typo_config.quote_hl,
		comments = typo_config.comment_hl,
		headers = typo_config.header_hl,
		dialogues = typo_config.dialogue_hl,
	}

	for section, gr_name in pairs(hl_groups) do -- why not working?
		if vim.fn.hlexists(gr_name) then
			vim.health.ok(gr_name .. " for " .. section)
		else
			vim.health.warn(
				gr_name .. " for " .. section,
				"Define this group in your nvim config or remove from plugin configurtion."
			)
		end
	end
end

local function check_draft_filetype()
	vim.health.start("associated filetype")
	if is_defined_filetype("draft") then
		vim.health.ok("filetype draft defined")
	else
		vim.health.warn(
			"filetype draft no defined",
			"Define this type in your nvim configuration or use draft.init_filetype()."
		)
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
	check_draft_filetype()
	check_hl_groups_config()
end
return M
