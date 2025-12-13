-- Required for code coverage
require("luacov")

-- Local modules
local markme
local state
local keybindings
local windower
local luaunit = require("luaunit")

TestMarkMe = {}

local function wipe_all_buffers()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) then
			-- force delete: removes buffer even if modified
			vim.api.nvim_buf_delete(buf, { force = true })
		end
	end
end

-- Setting up and tearing down for each test
function TestMarkMe:setup()
	markme = require("mark-me.markme")
	state = require("mark-me.state")
	keybindings = require("mark-me.keybindings")
	windower = require("mark-me.windower")
end

function TestMarkMe:teardown()
	package.loaded["mark-me.markme"] = nil
	package.loaded["mark-me.state"] = nil
	package.loaded["mark-me.keybindings"] = nil
	package.loaded["mark-me.windower"] = nil
	wipe_all_buffers()
end
-- End setup and teardown

function TestMarkMe:test_open_window_works_no_marks()
	markme.open_window()
	luaunit.assertNotNil(state.markBufHandle)
	luaunit.assertNotNil(state.windowHandle)
	luaunit.assertNil(state.selectedRow)
end

function TestMarkMe:test_open_window_works_with_marks()
	-- Set up state with some marks so we can test settin up all the additional calls to the modules
	state.marks = {
		{ line = 1, col = 1, buff_name = "another_name" },
		{ line = 2, col = 2, buff_name = "third_name" },
		{ line = 3, col = 3, buff_name = "fourth_name" },
	}
	state.markToBufMap = {
		{ line = 1, col = 1, buff_name = "another_name" },
		{ line = 2, col = 2, buff_name = "third_name" },
		{ line = 3, col = 3, buff_name = "fourth_name" },
	}
	state.currentMarkHandle = 2

	markme.open_window()
	luaunit.assertNotNil(state.markBufHandle)
	luaunit.assertNotNil(state.windowHandle)
	luaunit.assertNotNil(state.selectedRow)
end

function TestMarkMe:test_move_up_stack_no_selected_row()
	-- Set up state to prepare to move up a stack
	local buf_1 = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf_1, 0, 4, false, { "Line 1", "Line 2", "Line 3", "Line 4" })
	local buf_2 = vim.api.nvim_create_buf(false, true)
	local buf_3 = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_name(buf_1, "buf_1")
	vim.api.nvim_buf_set_name(buf_2, "buf_2")
	vim.api.nvim_buf_set_name(buf_3, "buf_3")
	state.marks = {
		{ line = 1, col = 1, buff_name = "buf_1" },
		{ line = 2, col = 2, buff_name = "buf_2" },
		{ line = 3, col = 3, buff_name = "buf_3" },
	}
	state.markToBufMap = {
		{ line = 1, col = 1, buff_name = "buf_1" },
		{ line = 2, col = 2, buff_name = "buf_2" },
		{ line = 3, col = 3, buff_name = "buf_3" },
	}
	state.currentMarkHandle = 2

	markme.move_up_stack()
	luaunit.assertEquals(vim.api.nvim_get_current_buf(), buf_1)
end

function TestMarkMe:test_move_up_stack_with_selected_row_without_autopop()
	-- Set up state to prepare to move up a stack
	local mark_buf = vim.api.nvim_create_buf(false, true)
	local buf_1 = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf_1, 0, 4, false, { "Line 1", "Line 2", "Line 3", "Line 4" })
	local buf_2 = vim.api.nvim_create_buf(false, true)
	local buf_3 = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_name(buf_1, "buf_1")
	vim.api.nvim_buf_set_name(buf_2, "buf_2")
	vim.api.nvim_buf_set_name(buf_3, "buf_3")
	state.marks = {
		{ line = 1, col = 1, buff_name = "buf_1" },
		{ line = 2, col = 2, buff_name = "buf_2" },
		{ line = 3, col = 3, buff_name = "buf_3" },
	}
	state.markToBufMap = {
		{ line = 1, col = 1, buff_name = "buf_1" },
		{ line = 2, col = 2, buff_name = "buf_2" },
		{ line = 3, col = 3, buff_name = "buf_3" },
	}
	state.markBufHandle = mark_buf
	state.currentMarkHandle = 2
	state.selectedRow = { line = 1, col = 1, buff_name = "buf_1" }

	markme.move_up_stack()
	luaunit.assertEquals(state.currentMarkHandle, 1)
	luaunit.assertEquals(vim.api.nvim_get_current_buf(), buf_1)
	luaunit.assertEquals(#state.marks, 3)
end

function TestMarkMe:test_move_down_stack_no_selected_row()
	-- Set up state to prepare to move down a stack
	local buf_1 = vim.api.nvim_create_buf(false, true)
	local buf_2 = vim.api.nvim_create_buf(false, true)
	local buf_3 = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_name(buf_1, "buf_1")
	vim.api.nvim_buf_set_name(buf_2, "buf_2")
	vim.api.nvim_buf_set_name(buf_3, "buf_3")
	vim.api.nvim_buf_set_lines(buf_3, 0, 4, false, { "Line 1", "Line 2", "Line 3", "Line 4" })
	state.marks = {
		{ line = 1, col = 1, buff_name = "buf_1" },
		{ line = 2, col = 2, buff_name = "buf_2" },
		{ line = 3, col = 3, buff_name = "buf_3" },
	}
	state.markToBufMap = {
		{ line = 1, col = 1, buff_name = "buf_1" },
		{ line = 2, col = 2, buff_name = "buf_2" },
		{ line = 3, col = 3, buff_name = "buf_3" },
	}
	state.currentMarkHandle = 2

	markme.move_down_stack()
	luaunit.assertEquals(vim.api.nvim_get_current_buf(), buf_3)
end

function TestMarkMe:test_move_down_stack_with_selected_row_without_autopop()
	-- Set up state to prepare to move down a stack
	local mark_buf = vim.api.nvim_create_buf(false, true)
	local buf_1 = vim.api.nvim_create_buf(false, true)
	local buf_2 = vim.api.nvim_create_buf(false, true)
	local buf_3 = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf_3, 0, 4, false, { "Line 1", "Line 2", "Line 3", "Line 4" })
	vim.api.nvim_buf_set_name(buf_1, "buf_1")
	vim.api.nvim_buf_set_name(buf_2, "buf_2")
	vim.api.nvim_buf_set_name(buf_3, "buf_3")
	state.marks = {
		{ line = 1, col = 1, buff_name = "buf_1" },
		{ line = 2, col = 2, buff_name = "buf_2" },
		{ line = 3, col = 3, buff_name = "buf_3" },
	}
	state.markToBufMap = {
		{ line = 1, col = 1, buff_name = "buf_1" },
		{ line = 2, col = 2, buff_name = "buf_2" },
		{ line = 3, col = 3, buff_name = "buf_3" },
	}
	state.markBufHandle = mark_buf
	state.currentMarkHandle = 2
	state.selectedRow = { line = 3, col = 3, buff_name = "buf_3" }

	markme.move_down_stack()
	luaunit.assertEquals(state.currentMarkHandle, 3)
	luaunit.assertEquals(vim.api.nvim_get_current_buf(), buf_3)
	luaunit.assertEquals(#state.marks, 3)
end

function TestMarkMe:test_go_to_mark_selected_row()
	-- Set up state to prepare to go to mark
	local mark_buf = vim.api.nvim_create_buf(false, true)
	local buf_1 = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf_1, 0, 4, false, { "Line 1", "Line 2", "Line 3", "Line 4" })
	local buf_2 = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf_2, 0, 4, false, { "Line 1", "Line 2", "Line 3", "Line 4" })
	local buf_3 = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_name(buf_1, "buf_1")
	vim.api.nvim_buf_set_name(buf_2, "buf_2")
	vim.api.nvim_buf_set_name(buf_3, "buf_3")
	state.marks = {
		{ line = 1, col = 1, buff_name = "buf_1" },
		{ line = 2, col = 2, buff_name = "buf_2" },
		{ line = 3, col = 3, buff_name = "buf_3" },
	}
	state.markToBufMap = {
		{ line = 1, col = 1, buff_name = "buf_1" },
		{ line = 2, col = 2, buff_name = "buf_2" },
		{ line = 3, col = 3, buff_name = "buf_3" },
	}
	state.markBufHandle = mark_buf
	state.currentMarkHandle = 2
	state.selectedRow = { line = 1, col = 1, buff_name = "buf_1" }

	markme.go_to_mark()
	luaunit.assertEquals(state.currentMarkHandle, 2)
	luaunit.assertEquals(vim.api.nvim_get_current_buf(), buf_1)
	luaunit.assertEquals(#state.marks, 3)
end
