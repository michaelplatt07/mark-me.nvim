local markme = require("mark-me.markme")
local state = require("mark-me.state")
local M = {}

function M.setup(config)
	if config ~= nil then
		if config.autopop ~= nil and config.autopop == true then
			state.autopop = true
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
	if state.autopop then
		markme.pop_and_go_back()
	else
		markme.go_back_mark()
	end
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
