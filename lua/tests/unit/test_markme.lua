-- Mock Vim so we can mock returns on method bindings
vim = {
	api = {},
}
-- End mocking

-- Required for code coverage
require("luacov")

-- Local modules
local luaunit = require("luaunit")
local markme

TestMarkMe = {}

-- Setting up and tearing down for each test
function TestMarkMe:setup()
	markme = require("mark-me.markme")
end

function TestMarkMe:teardown()
	package.loaded["mark-me.markMe"] = nil
	package.loaded["mark-me.state"] = nil
end
-- End setup and teardown

function TestMarkMe.test_add_mark_to_state()
	vim.api.nvim_buf_get_name = function()
		return "test_name"
	end
	vim.api.nvim_win_get_cursor = function()
		return { 2, 3 }
	end

	luaunit.assertEquals(#markme.state.marks, 0)
	markme.add_mark()
	luaunit.assertEquals(#markme.state.marks, 1)
	luaunit.assertEquals(markme.state.marks[1], { line = 2, col = 3, buff_name = "test_name" })
	luaunit.assertEquals(markme.state.display_mark(1), "2 | 3 | test_name")
end

function TestMarkMe.test_remove_mark_from_state()
	vim.api.nvim_win_get_cursor = function()
		return { 2, 3 }
	end
	vim.api.nvim_buf_clear_namespace = function() end

	-- Set up the state to have several marks saved
	markme.state.marks = {
		{ line = 0, col = 0, buff_name = "first_buffer" },
		{ line = 1, col = 1, buff_name = "second_buffer" },
		{ line = 2, col = 2, buff_name = "third_buffer" },
		{ line = 3, col = 3, buff_name = "fourth_buffer" },
	}
	markme.state.markToBufMap = {
		{ line = 0, col = 0, buff_name = "first_buffer" },
		{ line = 1, col = 1, buff_name = "second_buffer" },
		{ line = 2, col = 2, buff_name = "third_buffer" },
		{ line = 3, col = 3, buff_name = "fourth_buffer" },
	}

	luaunit.assertEquals(markme.state.marks[2], { line = 1, col = 1, buff_name = "second_buffer" })
	markme.remove_mark()
	luaunit.assertEquals(markme.state.marks[2], { line = 2, col = 2, buff_name = "third_buffer" })
end

function TestMarkMe.test_move_mark_up_at_top_position()
	vim.api.nvim_win_get_cursor = function()
		return { 1, 3 }
	end

	-- Set the state so the mark is at the top of list of marks
	markme.state.currentMarkHandle = 1
	markme.state.marks = {
		{ line = 0, col = 0, buff_name = "first_buffer" },
		{ line = 1, col = 1, buff_name = "second_buffer" },
		{ line = 2, col = 2, buff_name = "third_buffer" },
		{ line = 3, col = 3, buff_name = "fourth_buffer" },
	}
	markme.state.markToBufMap = {
		{ line = 0, col = 0, buff_name = "first_buffer" },
		{ line = 1, col = 1, buff_name = "second_buffer" },
		{ line = 2, col = 2, buff_name = "third_buffer" },
		{ line = 3, col = 3, buff_name = "fourth_buffer" },
	}

	markme.move_mark_up()
	luaunit.assertEquals(markme.state.marks[1], { line = 0, col = 0, buff_name = "first_buffer" })
	luaunit.assertEquals(markme.state.currentMarkHandle, 1)
end

function TestMarkMe.test_move_mark_up()
	vim.api.nvim_win_get_cursor = function()
		return { 2, 3 }
	end

	-- Set the state so there are several marks
	markme.state.currentMarkHandle = 2
	markme.state.marks = {
		{ line = 0, col = 0, buff_name = "first_buffer" },
		{ line = 1, col = 1, buff_name = "second_buffer" },
		{ line = 2, col = 2, buff_name = "third_buffer" },
		{ line = 3, col = 3, buff_name = "fourth_buffer" },
	}
	markme.state.markToBufMap = {
		{ line = 0, col = 0, buff_name = "first_buffer" },
		{ line = 1, col = 1, buff_name = "second_buffer" },
		{ line = 2, col = 2, buff_name = "third_buffer" },
		{ line = 3, col = 3, buff_name = "fourth_buffer" },
	}

	luaunit.assertEquals(markme.state.marks[1], { line = 0, col = 0, buff_name = "first_buffer" })
	luaunit.assertEquals(markme.state.markToBufMap[1], { line = 0, col = 0, buff_name = "first_buffer" })
	markme.move_mark_up()
	luaunit.assertEquals(markme.state.marks[1], { line = 1, col = 1, buff_name = "second_buffer" })
	luaunit.assertEquals(markme.state.markToBufMap[1], { line = 1, col = 1, buff_name = "second_buffer" })
	luaunit.assertEquals(markme.state.currentMarkHandle, 1)
end

function TestMarkMe.test_move_mark_down_at_bottom_position()
	vim.api.nvim_win_get_cursor = function()
		return { 4, 3 }
	end

	-- Set the state so the mark is at the bottom of list of marks
	markme.state.currentMarkHandle = 4
	markme.state.marks = {
		{ line = 0, col = 0, buff_name = "first_buffer" },
		{ line = 1, col = 1, buff_name = "second_buffer" },
		{ line = 2, col = 2, buff_name = "third_buffer" },
		{ line = 3, col = 3, buff_name = "fourth_buffer" },
	}
	markme.state.markToBufMap = {
		{ line = 0, col = 0, buff_name = "first_buffer" },
		{ line = 1, col = 1, buff_name = "second_buffer" },
		{ line = 2, col = 2, buff_name = "third_buffer" },
		{ line = 3, col = 3, buff_name = "fourth_buffer" },
	}

	markme.move_mark_down()
	luaunit.assertEquals(markme.state.marks[4], { line = 3, col = 3, buff_name = "fourth_buffer" })
	luaunit.assertEquals(markme.state.currentMarkHandle, 4)
end

function TestMarkMe.test_move_mark_down()
	vim.api.nvim_win_get_cursor = function()
		return { 2, 3 }
	end

	-- Set the state so there are several marks
	markme.state.currentMarkHandle = 2
	markme.state.marks = {
		{ line = 0, col = 0, buff_name = "first_buffer" },
		{ line = 1, col = 1, buff_name = "second_buffer" },
		{ line = 2, col = 2, buff_name = "third_buffer" },
		{ line = 3, col = 3, buff_name = "fourth_buffer" },
	}
	markme.state.markToBufMap = {
		{ line = 0, col = 0, buff_name = "first_buffer" },
		{ line = 1, col = 1, buff_name = "second_buffer" },
		{ line = 2, col = 2, buff_name = "third_buffer" },
		{ line = 3, col = 3, buff_name = "fourth_buffer" },
	}

	markme.move_mark_down()
	luaunit.assertEquals(markme.state.marks[3], { line = 1, col = 1, buff_name = "second_buffer" })
	luaunit.assertEquals(markme.state.markToBufMap[3], { line = 1, col = 1, buff_name = "second_buffer" })
	luaunit.assertEquals(markme.state.currentMarkHandle, 3)
end

return TestMarkMe
