-- Main moduel
---@class Draft
local draft = {}

---@param opts table Options configured by user
function draft.setup(opts)
	local config = require("draft.config").setup(opts).configuration

	if config.core then
		require("draft.core").setup()
	end
	if config.paginator then
		require("draft.paginator").setup()
	end
	if config.typography then
		require("draft.typography").setup()
	end
end

return draft
