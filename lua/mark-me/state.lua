local state = {
	marks = {},
	selectedRow = nil,
	windowHandle = nil,
	markBufHandle = nil,
	currentMarkHandle = nil,
	autopop = nil,
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
		state.currentMarkHandle = #state.marks
	end
end

--- Removes the given mark from the state
---@param idx number The mark that should be removed from the list of marks
function state.remove_mark(idx)
	table.remove(state.marks, idx)
	state.currentMarkHandle = #state.marks
end

--- Moves marks up in the list
--- @param rowIdx number The current row that will be moved up by one
function state.move_mark_up(rowIdx)
	if rowIdx - 1 > 0 then
		local tmpMark = state.marks[rowIdx - 1]
		-- Update the marks list
		state.marks[rowIdx - 1] = state.marks[rowIdx]
		state.marks[rowIdx] = tmpMark

		-- Conditionally update the current mark handle if it was moved to update highlighted row and such
		if rowIdx == state.currentMarkHandle then
			state.currentMarkHandle = rowIdx - 1
		elseif rowIdx - 1 == state.currentMarkHandle then
			state.currentMarkHandle = rowIdx
		end
	end
end

--- Moves marks down in the list
--- @param rowIdx number The current row that will be moved down by one
function state.move_mark_down(rowIdx)
	if rowIdx + 1 <= #state.marks then
		local tmpMark = state.marks[rowIdx + 1]
		-- Update the marks list
		state.marks[rowIdx + 1] = state.marks[rowIdx]
		state.marks[rowIdx] = tmpMark

		-- Conditionally update the current mark handle if it was moved to update highlighted row and such
		if rowIdx == state.currentMarkHandle then
			state.currentMarkHandle = rowIdx + 1
		elseif rowIdx + 1 == state.currentMarkHandle then
			state.currentMarkHandle = rowIdx
		end
	end
end

--- Pop the value off the stack as part of going back in the buffer stack
--- @param selectedIdx number The index of the buffer to be popped off the stack. If nil is provided it will remove the most recently added value
function state.pop_mark(selectedIdx)
	table.remove(state.marks, selectedIdx)

	if state.currentMarkHandle - 1 > 0 then
		state.currentMarkHandle = state.currentMarkHandle - 1
	end
end

-- luacov: disable

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

-- luacov: enable

return state
