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

function M.go_back_mark()
	markme.go_back_mark()
end

function M.go_forward_mark()
	markme.go_forward_mark()
end

function M.go_to_mark()
	markme.go_to_mark()
end

return M
