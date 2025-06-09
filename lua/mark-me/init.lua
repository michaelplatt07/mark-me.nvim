local markme = require("mark-me.markme")
local state = require("mark-me.state")
local M = {}

function M.setup(config)
	if config ~= nil then
		if config.keys ~= nil then
			for func, custombind in pairs(config.keys) do
				if config.auto_pop ~= nil and config.auto_pop == true then
					state.autopop = true
				end
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

function M.pop_and_go_back()
	markme.pop_and_go_back()
end

return M
