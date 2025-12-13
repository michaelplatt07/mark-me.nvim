-- Set the path so local installed rocks can be imported
package.path = ".luarocks/share/lua/5.3/?.lua;" .. package.path
-- Set the path so local modules from the plugin can be imported
package.path = "./lua/?.lua;" .. package.path

local state
local luaunit = require("luaunit")

-- Mock Vim so we can mock returns on method bindings
vim = {
	api = {},
}
-- End mocking

require("luacov")

TestState = {}

-- Setting up and tearing down for each test
function TestState:setup()
	state = require("mark-me.state")
end

function TestState:teardown()
	package.loaded["mark-me.state"] = nil
end
-- End setup and teardown

function TestState.test_has_dup_returns_false_for_empty()
	local has_dup = state.has_dup(0, 0, "test_name")
	luaunit.assertEquals(has_dup, false)
end

function TestState.test_has_dup_returns_false_for_non_empty()
	table.insert(state.marks, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.marks, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.marks, { line = 3, col = 3, buff_name = "fourth_name" })
	local has_dup = state.has_dup(0, 0, "test_name")
	luaunit.assertEquals(has_dup, false)
end

function TestState.test_has_dup_returns_true_for_non_empty()
	table.insert(state.marks, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.marks, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.marks, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.marks, { line = 3, col = 3, buff_name = "fourth_name" })
	local has_dup = state.has_dup(0, 0, "test_name")
	luaunit.assertEquals(has_dup, true)
end

function TestState.test_add_mark_no_dup()
	luaunit.assertEquals(state.currentMarkHandle, nil)
	luaunit.assertEquals(#state.marks, 0)
	state.add_mark(0, 1, "this_is_a_buffer_name")
	luaunit.assertEquals(#state.marks, 1)
	luaunit.assertEquals(state.currentMarkHandle, 1)
	luaunit.assertEquals(state.markToBufMap[1], { line = 0, col = 1, buff_name = "this_is_a_buffer_name" })
	luaunit.assertEquals(state.marks[1], { line = 0, col = 1, buff_name = "this_is_a_buffer_name" })
end

function TestState.test_add_mark_with_dup()
	table.insert(state.marks, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.marks, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.marks, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.marks, { line = 3, col = 3, buff_name = "fourth_name" })
	table.insert(state.markToBufMap, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.markToBufMap, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.markToBufMap, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.markToBufMap, { line = 3, col = 3, buff_name = "fourth_name" })
	state.currentMarkHandle = 4
	luaunit.assertEquals(state.currentMarkHandle, 4)
	luaunit.assertEquals(#state.marks, 4)
	state.add_mark(0, 0, "test_name")
	luaunit.assertEquals(state.currentMarkHandle, 4)
	luaunit.assertEquals(#state.markToBufMap, 4)
	luaunit.assertEquals(#state.marks, 4)
end

function TestState.test_add_mark_same_buff_different_line()
	table.insert(state.marks, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.marks, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.marks, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.marks, { line = 3, col = 3, buff_name = "fourth_name" })
	table.insert(state.markToBufMap, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.markToBufMap, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.markToBufMap, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.markToBufMap, { line = 3, col = 3, buff_name = "fourth_name" })
	state.currentMarkHandle = 4
	luaunit.assertEquals(#state.marks, 4)
	luaunit.assertEquals(state.currentMarkHandle, 4)
	state.add_mark(10, 0, "this_is_a_buffer_name")
	luaunit.assertEquals(state.currentMarkHandle, 5)
	luaunit.assertEquals(state.marks[5], { line = 10, col = 0, buff_name = "this_is_a_buffer_name" })
	luaunit.assertEquals(state.markToBufMap[5], { line = 10, col = 0, buff_name = "this_is_a_buffer_name" })
	luaunit.assertEquals(#state.marks, 5)
	luaunit.assertEquals(#state.markToBufMap, 5)
end

function TestState.test_add_mark_same_buff_different_col()
	table.insert(state.marks, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.marks, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.marks, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.marks, { line = 3, col = 3, buff_name = "fourth_name" })
	table.insert(state.markToBufMap, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.markToBufMap, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.markToBufMap, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.markToBufMap, { line = 3, col = 3, buff_name = "fourth_name" })
	state.currentMarkHandle = 4
	luaunit.assertEquals(#state.marks, 4)
	luaunit.assertEquals(state.currentMarkHandle, 4)
	state.add_mark(0, 100, "this_is_a_buffer_name")
	luaunit.assertEquals(state.currentMarkHandle, 5)
	luaunit.assertEquals(state.marks[5], { line = 0, col = 100, buff_name = "this_is_a_buffer_name" })
	luaunit.assertEquals(state.markToBufMap[5], { line = 0, col = 100, buff_name = "this_is_a_buffer_name" })
	luaunit.assertEquals(#state.marks, 5)
	luaunit.assertEquals(#state.markToBufMap, 5)
end

function TestState.test_remove_mark_out_of_bounds()
	table.insert(state.marks, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.marks, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.marks, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.marks, { line = 3, col = 3, buff_name = "fourth_name" })
	local ok, err = pcall(function()
		state.remove_mark(10)
	end)
	luaunit.assertFalse(ok)
	luaunit.assertEquals(tostring(err), "./lua/mark-me/state.lua:52: Idx is out of bounds for state")
	luaunit.assertEquals(state.marks[1], { line = 0, col = 0, buff_name = "test_name" })
	luaunit.assertEquals(#state.marks, 4)
end

function TestState.test_remove_mark()
	table.insert(state.marks, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.marks, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.marks, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.marks, { line = 3, col = 3, buff_name = "fourth_name" })
	table.insert(state.markToBufMap, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.markToBufMap, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.markToBufMap, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.markToBufMap, { line = 3, col = 3, buff_name = "fourth_name" })
	state.currentMarkHandle = 4
	luaunit.assertEquals(state.currentMarkHandle, 4)
	state.remove_mark(1)
	luaunit.assertEquals(state.currentMarkHandle, 3)
	luaunit.assertEquals(state.marks[1], { line = 1, col = 1, buff_name = "another_name" })
	luaunit.assertEquals(state.markToBufMap[1], { line = 1, col = 1, buff_name = "another_name" })
	luaunit.assertEquals(#state.marks, 3)
	luaunit.assertEquals(#state.markToBufMap, 3)
end

function TestState.test_remove_mark_middle_of_list()
	table.insert(state.marks, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.marks, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.marks, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.marks, { line = 3, col = 3, buff_name = "fourth_name" })
	table.insert(state.markToBufMap, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.markToBufMap, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.markToBufMap, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.markToBufMap, { line = 3, col = 3, buff_name = "fourth_name" })
	state.currentMarkHandle = 4
	luaunit.assertEquals(state.currentMarkHandle, 4)
	state.remove_mark(3)
	luaunit.assertEquals(state.currentMarkHandle, 3)
	luaunit.assertEquals(state.marks[3], { line = 3, col = 3, buff_name = "fourth_name" })
	luaunit.assertEquals(state.markToBufMap[3], { line = 3, col = 3, buff_name = "fourth_name" })
	luaunit.assertEquals(#state.marks, 3)
	luaunit.assertEquals(#state.markToBufMap, 3)
end

function TestState.test_display_mark()
	table.insert(state.marks, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.marks, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.marks, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.marks, { line = 3, col = 3, buff_name = "fourth_name" })
	local display_mark = state.display_mark(1)
	luaunit.assertEquals(display_mark, "0 | 0 | test_name")
end

function TestState.test_display_mark_middle_of_list()
	table.insert(state.marks, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.marks, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.marks, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.marks, { line = 3, col = 3, buff_name = "fourth_name" })
	local display_mark = state.display_mark(3)
	luaunit.assertEquals(display_mark, "2 | 2 | third_name")
end

function TestState.test_update_selected_row()
	vim.api.nvim_win_get_cursor = function()
		return { 3, 0 }
	end

	table.insert(state.markToBufMap, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.markToBufMap, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.markToBufMap, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.markToBufMap, { line = 3, col = 3, buff_name = "fourth_name" })
	state.update_selected_row()
	luaunit.assertEquals(state.selectedRow, { line = 2, col = 2, buff_name = "third_name" })
end

function TestState.test_move_mark_up_not_current_buffer()
	table.insert(state.marks, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.marks, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.marks, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.marks, { line = 3, col = 3, buff_name = "fourth_name" })
	table.insert(state.markToBufMap, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.markToBufMap, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.markToBufMap, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.markToBufMap, { line = 3, col = 3, buff_name = "fourth_name" })
	state.currentMarkHandle = 3
	luaunit.assertEquals(state.marks[2], { line = 1, col = 1, buff_name = "another_name" })
	luaunit.assertEquals(state.markToBufMap[2], { line = 1, col = 1, buff_name = "another_name" })
	state.move_mark_up(2)
	luaunit.assertEquals(state.currentMarkHandle, 3)
	luaunit.assertEquals(state.marks[1], { line = 1, col = 1, buff_name = "another_name" })
	luaunit.assertEquals(state.markToBufMap[1], { line = 1, col = 1, buff_name = "another_name" })
end

function TestState.test_move_mark_up_swapping_current_buffer()
	table.insert(state.marks, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.marks, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.marks, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.marks, { line = 3, col = 3, buff_name = "fourth_name" })
	table.insert(state.markToBufMap, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.markToBufMap, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.markToBufMap, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.markToBufMap, { line = 3, col = 3, buff_name = "fourth_name" })
	state.currentMarkHandle = 1
	luaunit.assertEquals(state.marks[2], { line = 1, col = 1, buff_name = "another_name" })
	luaunit.assertEquals(state.markToBufMap[2], { line = 1, col = 1, buff_name = "another_name" })
	state.move_mark_up(2)
	luaunit.assertEquals(state.currentMarkHandle, 2)
	luaunit.assertEquals(state.marks[1], { line = 1, col = 1, buff_name = "another_name" })
	luaunit.assertEquals(state.markToBufMap[1], { line = 1, col = 1, buff_name = "another_name" })
end

function TestState.test_move_mark_up_current_buffer_selected()
	table.insert(state.marks, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.marks, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.marks, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.marks, { line = 3, col = 3, buff_name = "fourth_name" })
	table.insert(state.markToBufMap, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.markToBufMap, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.markToBufMap, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.markToBufMap, { line = 3, col = 3, buff_name = "fourth_name" })
	state.currentMarkHandle = 2
	luaunit.assertEquals(state.marks[2], { line = 1, col = 1, buff_name = "another_name" })
	luaunit.assertEquals(state.markToBufMap[2], { line = 1, col = 1, buff_name = "another_name" })
	state.move_mark_up(2)
	luaunit.assertEquals(state.currentMarkHandle, 1)
	luaunit.assertEquals(state.marks[1], { line = 1, col = 1, buff_name = "another_name" })
	luaunit.assertEquals(state.markToBufMap[1], { line = 1, col = 1, buff_name = "another_name" })
end

function TestState.test_move_mark_up_out_of_bounds()
	table.insert(state.marks, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.marks, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.marks, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.marks, { line = 3, col = 3, buff_name = "fourth_name" })
	table.insert(state.markToBufMap, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.markToBufMap, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.markToBufMap, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.markToBufMap, { line = 3, col = 3, buff_name = "fourth_name" })
	state.currentMarkHandle = 1
	luaunit.assertEquals(state.markToBufMap[1], { line = 0, col = 0, buff_name = "test_name" })
	state.move_mark_up(1)
	luaunit.assertEquals(state.currentMarkHandle, 1)
	luaunit.assertEquals(state.markToBufMap[1], { line = 0, col = 0, buff_name = "test_name" })
end

function TestState.test_move_mark_down_not_current_buffer()
	table.insert(state.marks, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.marks, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.marks, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.marks, { line = 3, col = 3, buff_name = "fourth_name" })
	table.insert(state.markToBufMap, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.markToBufMap, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.markToBufMap, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.markToBufMap, { line = 3, col = 3, buff_name = "fourth_name" })
	state.currentMarkHandle = 1
	luaunit.assertEquals(state.marks[2], { line = 1, col = 1, buff_name = "another_name" })
	luaunit.assertEquals(state.markToBufMap[2], { line = 1, col = 1, buff_name = "another_name" })
	state.move_mark_down(2)
	luaunit.assertEquals(state.currentMarkHandle, 1)
	luaunit.assertEquals(state.marks[3], { line = 1, col = 1, buff_name = "another_name" })
	luaunit.assertEquals(state.markToBufMap[3], { line = 1, col = 1, buff_name = "another_name" })
end

function TestState.test_move_mark_down_swapping_current_buffer()
	table.insert(state.marks, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.marks, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.marks, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.marks, { line = 3, col = 3, buff_name = "fourth_name" })
	table.insert(state.markToBufMap, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.markToBufMap, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.markToBufMap, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.markToBufMap, { line = 3, col = 3, buff_name = "fourth_name" })
	state.currentMarkHandle = 3
	luaunit.assertEquals(state.marks[2], { line = 1, col = 1, buff_name = "another_name" })
	luaunit.assertEquals(state.markToBufMap[2], { line = 1, col = 1, buff_name = "another_name" })
	state.move_mark_down(2)
	luaunit.assertEquals(state.currentMarkHandle, 2)
	luaunit.assertEquals(state.marks[3], { line = 1, col = 1, buff_name = "another_name" })
	luaunit.assertEquals(state.markToBufMap[3], { line = 1, col = 1, buff_name = "another_name" })
end

function TestState.test_move_mark_down_current_buffer_selected()
	table.insert(state.marks, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.marks, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.marks, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.marks, { line = 3, col = 3, buff_name = "fourth_name" })
	table.insert(state.markToBufMap, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.markToBufMap, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.markToBufMap, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.markToBufMap, { line = 3, col = 3, buff_name = "fourth_name" })
	state.currentMarkHandle = 2
	luaunit.assertEquals(state.marks[2], { line = 1, col = 1, buff_name = "another_name" })
	luaunit.assertEquals(state.markToBufMap[2], { line = 1, col = 1, buff_name = "another_name" })
	state.move_mark_down(2)
	luaunit.assertEquals(state.currentMarkHandle, 3)
	luaunit.assertEquals(state.marks[3], { line = 1, col = 1, buff_name = "another_name" })
	luaunit.assertEquals(state.markToBufMap[3], { line = 1, col = 1, buff_name = "another_name" })
end

function TestState.test_move_mark_down_out_of_bounds()
	table.insert(state.marks, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.marks, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.marks, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.marks, { line = 3, col = 3, buff_name = "fourth_name" })
	table.insert(state.markToBufMap, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.markToBufMap, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.markToBufMap, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.markToBufMap, { line = 3, col = 3, buff_name = "fourth_name" })
	state.currentMarkHandle = 4
	luaunit.assertEquals(state.markToBufMap[4], { line = 3, col = 3, buff_name = "fourth_name" })
	state.move_mark_down(4)
	luaunit.assertEquals(state.currentMarkHandle, 4)
	luaunit.assertEquals(state.markToBufMap[4], { line = 3, col = 3, buff_name = "fourth_name" })
end

function TestState.go_back_buffer_in_stack_out_of_bounds()
	table.insert(state.marks, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.marks, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.marks, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.marks, { line = 3, col = 3, buff_name = "fourth_name" })
	state.currentMarkHandle = 1
	state.move_up_stack()
	luaunit.assertEquals(state.currentMarkHandle, 1)
end

function TestState.go_back_buffer_in_stack()
	table.insert(state.marks, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.marks, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.marks, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.marks, { line = 3, col = 3, buff_name = "fourth_name" })
	state.currentMarkHandle = 3
	state.move_up_stack()
	luaunit.assertEquals(state.currentMarkHandle, 2)
end

function TestState.go_forward_buffer_in_stack()
	table.insert(state.marks, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.marks, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.marks, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.marks, { line = 3, col = 3, buff_name = "fourth_name" })
	state.currentMarkHandle = 2
	state.move_down_stack()
	luaunit.assertEquals(state.currentMarkHandle, 3)
end

function TestState.go_forward_buffer_in_stack_out_of_bounds()
	table.insert(state.marks, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.marks, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.marks, { line = 2, col = 2, buff_name = "third_name" })
	table.insert(state.marks, { line = 3, col = 3, buff_name = "fourth_name" })
	state.currentMarkHandle = 4
	state.move_down_stack()
	luaunit.assertEquals(state.currentMarkHandle, 4)
end

function TestState.test_pop_from_stack_nil_value()
	table.insert(state.marks, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.marks, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.markToBufMap, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.markToBufMap, { line = 1, col = 1, buff_name = "another_name" })
	state.currentMarkHandle = 2
	luaunit.assertEquals(#state.marks, 2)
	luaunit.assertEquals(#state.markToBufMap, 2)
	state.pop_mark(nil)
	luaunit.assertEquals(#state.marks, 1)
	luaunit.assertEquals(#state.markToBufMap, 1)
	luaunit.assertEquals(state.currentMarkHandle, 1)
end

function TestState.test_pop_from_stack_given_value_at_beginning()
	table.insert(state.marks, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.marks, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.markToBufMap, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.markToBufMap, { line = 1, col = 1, buff_name = "another_name" })
	state.currentMarkHandle = 2
	luaunit.assertEquals(#state.marks, 2)
	luaunit.assertEquals(#state.markToBufMap, 2)
	state.pop_mark(1)
	luaunit.assertEquals(#state.marks, 1)
	luaunit.assertEquals(#state.markToBufMap, 1)
	luaunit.assertEquals(state.currentMarkHandle, 1)
	luaunit.assertEquals(state.marks[1], { line = 1, col = 1, buff_name = "another_name" })
	luaunit.assertEquals(state.markToBufMap[1], { line = 1, col = 1, buff_name = "another_name" })
end

function TestState.test_pop_from_stack_given_value_at_end()
	table.insert(state.marks, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.marks, { line = 1, col = 1, buff_name = "another_name" })
	table.insert(state.markToBufMap, { line = 0, col = 0, buff_name = "test_name" })
	table.insert(state.markToBufMap, { line = 1, col = 1, buff_name = "another_name" })
	state.currentMarkHandle = 1
	luaunit.assertEquals(#state.marks, 2)
	luaunit.assertEquals(#state.markToBufMap, 2)
	state.pop_mark(2)
	luaunit.assertEquals(#state.marks, 1)
	luaunit.assertEquals(#state.markToBufMap, 1)
	luaunit.assertEquals(state.currentMarkHandle, 1)
	luaunit.assertEquals(state.marks[1], { line = 0, col = 0, buff_name = "test_name" })
	luaunit.assertEquals(state.markToBufMap[1], { line = 0, col = 0, buff_name = "test_name" })
end

function TestState.test_move_mark_up_by_num()
	-- luaunit.assertFalse("TODO(map) Implement feature to move a mark up by some number")
end

function TestState.test_move_mark_down_by_num()
	-- luaunit.assertFalse("TODO(map) Implement feature to move mark down by some number")
end

return TestState
