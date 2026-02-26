local state = require("mark-me.state")
local windower = {}

-- luacov: disable
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
-- luacov: enable

function windower.render_mark_list_lines()
	vim.api.nvim_buf_set_option(state.markBufHandle, "modifiable", true)
	local lines = {}
	for idx, _ in pairs(state.marks) do
		table.insert(lines, state.display_mark(idx))
	end

	vim.api.nvim_buf_set_lines(state.markBufHandle, 0, #lines, false, lines)
	if #state.marks > 0 then
		windower.highlight_current_mark(state.currentMarkHandle)
	end
	vim.api.nvim_buf_set_option(state.markBufHandle, "modifiable", false)
end

function windower.re_render_mark_list_lines()
	vim.api.nvim_buf_set_option(state.markBufHandle, "modifiable", true)
	vim.api.nvim_buf_set_lines(state.markBufHandle, 0, -1, false, {})
	local lines = {}
	for idx, _ in ipairs(state.marks) do
		table.insert(lines, state.display_mark(idx))
	end

	vim.api.nvim_buf_set_lines(state.markBufHandle, 0, #lines, false, lines)
	if #state.marks > 0 then
		windower.highlight_current_mark(state.currentMarkHandle)
	end
	vim.api.nvim_buf_set_option(state.markBufHandle, "modifiable", false)
end

function windower.close_window()
	-- TODO(map) This is another example of Feature #10 that should be fixed. The windower shouldn't cal the state, it
	-- should only handle windowing stuff.
	-- Clean up the state
	state.clear_selected_row()

	-- Reset modifiable flag so the buffer can be updated on the next search
	vim.api.nvim_buf_set_option(state.markBufHandle, "modifiable", true)

	-- Close the buffers and recreate them
	vim.api.nvim_buf_delete(state.markBufHandle, { force = true })
	state.markBufHandle = vim.api.nvim_create_buf(false, true)
end

--- Wrapper function around Neovim's line highlight functionality
--- @param line_num number The 1-indexed value of the line number
function windower.highlight_current_mark(line_num)
	-- Subtract one from the line_num value because lua is 1 indexed
	vim.api.nvim_buf_add_highlight(state.markBufHandle, -1, "CursorLine", line_num - 1, 0, -1)
end

--- Wrapper function around Neovim's line highlight removal functionality
--- @param line_num number The 1-indexed value of the line number
function windower.remove_highlight(line_num)
	vim.api.nvim_buf_clear_namespace(state.markBufHandle, -1, line_num - 1, -1)
end

return windower
