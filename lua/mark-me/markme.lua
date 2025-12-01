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
end

--- Entry point for opening window
function markme.open_window()
	state.init_required_buffers()

	-- Callback for when the cursor moves around in the buffer
	vim.api.nvim_create_autocmd({ "CursorMoved" }, {
		buffer = state.markBufHandle,
		callback = function()
			if #state.marks > 0 then
				state.update_selected_row()
			end
		end,
	})

	state.windowHandle = windower.create_mark_list_window()
	windower.render_mark_list_lines()

	-- Set the first selected row
	state.selectedRow = state.markToBufMap[1]

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

function markme.move_up_stack()
	state.move_up_stack()
	markme.go_to_mark()
end

function markme.move_down_stack()
	state.move_down_stack()
	markme.go_to_mark()
end

-- TODO(map) This should probably have the vim.api stuff factored out so I can more easily unit test the code base
function markme.go_to_mark(mark_num)
	if mark_num then
		local selectedRow = state.markToBufMap[mark_num]
		local selected_buf_handle = vim.fn.bufnr(selectedRow["buff_name"])
		vim.api.nvim_set_current_buf(selected_buf_handle)
		vim.api.nvim_win_set_cursor(0, { selectedRow["line"], selectedRow["col"] })
		if state.autopop then
			state.pop_mark(mark_num)
		end
		state.clear_selected_row()
	elseif state.selectedRow then
		-- Set the current line if we have autopop so we know which line in the state to clear
		local curr_line = nil
		if state.autopop then
			curr_line = vim.api.nvim_win_get_cursor(0)[1]
		end

		-- Grab the selected buffer and its info
		local selectedRow = state.selectedRow
		local selected_buf_handle = vim.fn.bufnr(selectedRow["buff_name"])
		windower.close_window()
		vim.api.nvim_set_current_buf(selected_buf_handle)
		vim.api.nvim_win_set_cursor(0, { selectedRow["line"], selectedRow["col"] })
		if state.autopop then
			state.pop_mark(curr_line)
		end
		state.clear_selected_row()
	elseif state.currentMarkHandle then
		local selectedRow = state.markToBufMap[state.currentMarkHandle]
		local selected_buf_handle = vim.fn.bufnr(selectedRow["buff_name"])
		vim.api.nvim_set_current_buf(selected_buf_handle)
		vim.api.nvim_win_set_cursor(0, { selectedRow["line"], selectedRow["col"] })
		if state.autopop then
			state.pop_mark(state.currentMarkHandle)
		end
		state.clear_selected_row()
	else
		error("Could not get to mark")
	end
end

function markme.go_back_mark()
	if state.currentMarkHandle then
		-- Handle closing out the window first and then getting the info
		if state.selectedRow then
			windower.close_window()
		end
		state.move_up_stack()
		local selectedRow = state.markToBufMap[state.currentMarkHandle]
		local selected_buf_handle = vim.fn.bufnr(selectedRow["buff_name"])
		vim.api.nvim_set_current_buf(selected_buf_handle)
		vim.api.nvim_win_set_cursor(0, { selectedRow["line"], selectedRow["col"] })
		state.clear_selected_row(nil)
	else
		error("Could not get to mark")
	end
end

function markme.go_forward_mark()
	if state.currentMarkHandle then
		-- Handle closing out the window first and then getting the info
		if state.selectedRow then
			windower.close_window()
		end
		state.move_down_stack()
		local selectedRow = state.markToBufMap[state.currentMarkHandle]
		local selected_buf_handle = vim.fn.bufnr(selectedRow["buff_name"])
		vim.api.nvim_set_current_buf(selected_buf_handle)
		vim.api.nvim_win_set_cursor(0, { selectedRow["line"], selectedRow["col"] })
		state.clear_selected_row(nil)
	else
		error("Could not get to mark")
	end
end

function markme.pop_and_go_back()
	if state.currentMarkHandle then
		-- Handle closing out the window first and then getting the info
		if state.selectedRow then
			windower.close_window()
		end
		-- Pop first since this will handle updating the currentMarkHandle and then we can open
		local empty = state.pop_mark(nil)
		if empty == false then
			local selectedRow = state.markToBufMap[state.currentMarkHandle]
			local selected_buf_handle = vim.fn.bufnr(selectedRow["buff_name"])
			vim.api.nvim_set_current_buf(selected_buf_handle)
			vim.api.nvim_win_set_cursor(0, { selectedRow["line"], selectedRow["col"] })
			state.clear_selected_row(nil)
		end
	else
		error("Could not get to mark")
	end
end

return markme
