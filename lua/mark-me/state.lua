local state = {
	marks = {},
	markToBufMap = {},
	selectedRow = nil,
	windowHandle = nil,
	markBufHandle = nil,
}

--- Initializes the buffer that will be used to render within the window for the mark list
function state.init_required_buffers()
	if state.markBufHandle == nil then
		state.markBufHandle = vim.api.nvim_create_buf(false, true)
	end
end

--- Checks for a mark already in the mark list
---@param line number The line number of the mark
---@param col number The column number of the mark
---@param buff_name string The name of the buffer where the mark is set
---@return boolean is_dup Flag that represents whether the combination of line, column, and buffer name exists in the state
function state.has_dup(line, col, buff_name)
	local is_dup = false
	for _, val in ipairs(state.marks) do
		if val.line == line and val.col == col and val.buff_name == buff_name then
			is_dup = true
		end
	end
	return is_dup
end

--- Adds the mark to the marks of the state
---@param line number The line number of the mark
---@param col number The column number of the mark
---@param buff_name string The name of the buffer where the mark is set
function state.add_mark(line, col, buff_name)
	local has_dup = state.has_dup(line, col, buff_name)
	if not has_dup then
		table.insert(state.marks, { line = line, col = col, buff_name = buff_name })
	end
end

--- Removes the given mark from the state
---@param idx number The mark that should be removed from the list of marks
function state.remove_mark(idx)
	if idx > #state.marks then
		-- TODO(map) This should probably be better but for now would be ok
		error("Idx is out of bounds for state")
	end
	table.remove(state.marks, idx)
end

--- Returns the user friendly text to be displayed
---@param idx number The index of the row to show
function state.display_mark(idx)
	-- TODO(map) Should we return an error here if the index is out of bounds?
	local mark_info = state.marks[idx]
	return string.format("%d | %d | %s", mark_info.line, mark_info.col, mark_info.buff_name)
end

--- Clears the selected row from the state
function state.clear_selected_row()
	state.selectedRow = nil
end

--- Updates the selected row within the mark buffer
function state.update_selected_row()
	state.selectedRow = state.markToBufMap[vim.api.nvim_win_get_cursor(0)[1]]
end

return state
