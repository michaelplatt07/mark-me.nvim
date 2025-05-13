local markme = require("mark-me.markme")
local M = {}

function M.setup(config)
	if config ~= nil then
		if config.keys ~= nil then
			for func, custombind in pairs(config.keys) do
			end
		end
	end
end

function M.add_mark()
	markme.add_mark()
end

function M.open_window()
	markme.open_window()
end

return M
