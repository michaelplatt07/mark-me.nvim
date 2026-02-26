local markme = require("mark-me.markme")
local state = require("mark-me.state")
local keybindings = require("mark-me.keybindings")
local M = {}

function M.setup(config)
	if config ~= nil then
		if config.keys ~= nil then
			for func, custombind in pairs(config.keys) do
				keybindings.update_key_binding(func, custombind)
			end
		end
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
	markme.go_back_mark(state.autopop)
end

function M.go_back_mark_no_pop()
	markme.go_back_mark(false)
end

function M.go_forward_mark()
	markme.go_forward_mark()
end

return M
