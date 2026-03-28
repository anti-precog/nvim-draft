local function check_nvim_version()
	vim.health.start("draft requirements")
	local v = vim.version()
	if v.major == 0 and v.minor >= 10 and v.patch >= 0 then
		vim.health.ok("neovim version >= 0.10.0")
	else
		vim.health.warn("neovim version < 0.10.0")
	end
end

---@type Config
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

local M = {}
M.check = function()
	check_nvim_version()
	check_hl_groups_config()
end
return M
