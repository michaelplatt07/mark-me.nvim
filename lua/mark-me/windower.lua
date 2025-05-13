local state = require("mark-me.state")
local windower = {}

function windower.create_mark_list_window()
	return vim.api.nvim_open_win(state.markBufHandle, true, {
		relative = "editor",
		row = 0,
		col = 0,
		width = 100,
		height = 20,
		border = "double",
		style = "minimal",
		title = "Marks",
	})
end

function windower.render_mark_list_lines()
	local lines = {}
	for idx, markInfo in pairs(state.marks) do
		table.insert(state.markToBufMap, markInfo)
		table.insert(lines, state.display_mark(idx))
	end

	vim.api.nvim_buf_set_lines(state.markBufHandle, 0, #lines, false, lines)
	vim.api.nvim_buf_set_option(state.markBufHandle, "modifiable", false)
end

function windower.re_render_mark_list_lines()
	vim.api.nvim_buf_set_option(state.markBufHandle, "modifiable", true)
	vim.api.nvim_buf_set_lines(state.markBufHandle, 0, -1, false, {})
	local lines = {}
	state.markToBufMap = {}
	for idx, markInfo in ipairs(state.marks) do
		table.insert(state.markToBufMap, markInfo)
		table.insert(lines, state.display_mark(idx))
	end

	vim.api.nvim_buf_set_lines(state.markBufHandle, 0, #lines, false, lines)
	vim.api.nvim_buf_set_option(state.markBufHandle, "modifiable", false)
end

function windower.close_window()
	-- Clean up the state
	state.bufNumToLineNumMap = {}
	state.clear_selected_row()

	-- Reset modifiable flag so the buffer can be updated on the next search
	vim.api.nvim_buf_set_option(state.markBufHandle, "modifiable", true)

	-- Close the buffers and recreate them
	vim.api.nvim_buf_delete(state.markBufHandle, { force = true })
	state.markBufHandle = vim.api.nvim_create_buf(false, true)
end

return windower
