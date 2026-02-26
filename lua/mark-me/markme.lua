local state = require("mark-me.state")
local keybindings = require("mark-me.keybindings")
local windower = require("mark-me.windower")

local markme = {}

markme.state = state

--- Entry point for adding marks
function markme.add_mark()
	local buff_name = vim.api.nvim_buf_get_name(0)
	local cursor_info = vim.api.nvim_win_get_cursor(0)
	local line_num = cursor_info[1]
	local col_num = cursor_info[2]
	state.add_mark(line_num, col_num, buff_name)
end

--- Entry point for removing marks
function markme.remove_mark()
	local line_num = vim.api.nvim_win_get_cursor(0)[1]
	state.remove_mark(line_num)
	windower.remove_highlight(line_num)
end

--- Entry point for opening window
function markme.open_window()
	state.init_required_buffers()

	-- Callback for when the cursor moves around in the buffer
	vim.api.nvim_create_autocmd({ "CursorMoved" }, {
		buffer = state.markBufHandle,
		callback = function()
			if #state.marks > 0 then
				state.selectedRowNumber = vim.api.nvim_win_get_cursor(0)[1]
			end
		end,
	})

	state.windowHandle = windower.create_mark_list_window()
	windower.render_mark_list_lines()

	-- Set the first selected row
	state.selectedRowNumber = 1

	-- Initialize key bindings
	keybindings.map_keys(state.markBufHandle)
end

function markme.move_mark_up()
	local line_num = vim.api.nvim_win_get_cursor(0)[1]
	state.move_mark_up(line_num)
end

function markme.move_mark_down()
	local line_num = vim.api.nvim_win_get_cursor(0)[1]
	state.move_mark_down(line_num)
end

function markme.go_to_mark(autopop)
	-- Grab the selected buffer and its info
	local selectedRowNum = state.selectedRowNumber
	local selectedRow = state.marks[selectedRowNum]
	local selectedBufHandle = vim.fn.bufnr(selectedRow["buff_name"])
	windower.close_window()
	vim.api.nvim_set_current_buf(selectedBufHandle)
	vim.api.nvim_win_set_cursor(0, { selectedRow["line"], selectedRow["col"] })
	if autopop then
		state.pop_mark(selectedRowNum)
	end
	state.clear_selected_row()
end

function markme.go_back_mark(autopop)
	if state.currentMarkHandle - 1 > 0 then
		state.currentMarkHandle = state.currentMarkHandle - 1
	end
	local selectedRow = state.marks[state.currentMarkHandle]
	local selected_buf_handle = vim.fn.bufnr(selectedRow["buff_name"])
	vim.api.nvim_set_current_buf(selected_buf_handle)
	vim.api.nvim_win_set_cursor(0, { selectedRow["line"], selectedRow["col"] })
	if autopop then
		state.pop_mark(state.currentMarkHandle)
	end
	state.clear_selected_row(nil)
end

function markme.go_forward_mark()
	if state.currentMarkHandle + 1 <= #state.marks then
		state.currentMarkHandle = state.currentMarkHandle + 1
	end
	local selectedRow = state.marks[state.currentMarkHandle]
	local selected_buf_handle = vim.fn.bufnr(selectedRow["buff_name"])
	vim.api.nvim_set_current_buf(selected_buf_handle)
	vim.api.nvim_win_set_cursor(0, { selectedRow["line"], selectedRow["col"] })
	state.clear_selected_row(nil)
end

return markme
