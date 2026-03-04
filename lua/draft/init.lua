local M = {}
local ns_id = vim.api.nvim_create_namespace("prose-mode")
local group = vim.api.nvim_create_augroup("ProseMode", { clear = true })

local function update_visual_indent(buf)
	vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)
	for i = 0, vim.api.nvim_buf_line_count(buf) - 1 do
		vim.api.nvim_buf_set_extmark(buf, ns_id, i, 0, {
			virt_text = { { "  ", "NonText" } },
			virt_text_pos = "inline",
			hl_mode = "combine",
		})
	end
end

local function setup_vim()
	vim.opt_local.tabstop = 8
	vim.opt_local.shiftwidth = 8
	vim.opt_local.wrap = true
	vim.opt_local.breakindent = true
end

local function setup_buffer_replacement(em_dash, dash)
	vim.keymap.set("i", em_dash, "—", { buffer = true })
	vim.keymap.set("i", dash, "–", { buffer = true })
end

function M.setup(opts)
	-- Add new filetype [draft]
	vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
		pattern = "*.draft",
		group = group,
		callback = function()
			vim.bo.filetype = "draft" -- ustawienie własnego FileType
		end,
	})
	opts = opts or {}
	local filetypes = opts and opts.filetypes or { "draft" }

	--vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "TextChanged", "TextChangedI", "InsertLeave" }, {
	vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged" }, {
		group = group,
		callback = function(args)
			if vim.tbl_contains(filetypes, vim.bo[args.buf].filetype) then
				update_visual_indent(args.buf)
			end
		end,
	})

	local em_dash_key = opts.em_dash or "-"
	local dash_key = opts.dash or "="

	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		pattern = filetypes,
		callback = function()
			setup_vim()
			setup_buffer_replacement(em_dash_key, dash_key)
		end,
	})
end

return M
