---@class draft
local draft = {}

---@param opts table
function draft.setup(opts)
	local options = require("draft.config").setup(opts).options

	if options.core then
		require("draft.core").setup()
	end
	if options.paginator then
		require("draft.paginator").setup()
	end
	if options.typography then
		require("draft.typography").setup()
	end
end

return draft
