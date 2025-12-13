-- Required for code coverage
require("luacov")

-- Local modules
local state
local windower
local luaunit = require("luaunit")

TestWindower = {}

-- Setting up and tearing down for each test
function TestWindower:setup()
	state = require("mark-me.state")
	windower = require("mark-me.windower")
end

function TestWindower:teardown()
	package.loaded["mark-me.state"] = nil
	package.loaded["mark-me.windower"] = nil
end
-- End setup and teardown

function TestWindower:test_render_mark_list_lines_with_no_highlight()
	-- Create a real buffer
	local buf = vim.api.nvim_create_buf(false, true)

	-- Set up the state as it would be for when a render is called and no highlight would be needed
	state.markBufHandle = buf
	state.marks = {}
	state.markToBufMap = {}

	-- Call the render
	windower.render_mark_list_lines()

	-- Confirm there are no highlights and the contents of buffer are as expected
	luaunit.assertEquals(#vim.api.nvim_buf_get_extmarks(buf, -1, 0, -1, { details = true }), 0)
	luaunit.assertEquals(vim.api.nvim_buf_get_lines(buf, 0, -1, false), { "" })
end

function TestWindower:test_render_mark_list_lines_with_highlight()
	-- Create a real buffer
	local buf = vim.api.nvim_create_buf(false, true)

	-- Set up the state as it would be for when a a render is called and a highlight should be present
	state.markBufHandle = buf
	state.currentMarkHandle = 2
	state.marks =
		{ { line = 1, col = 1, buff_name = "Sample Buf 1" }, { line = 2, col = 2, buff_name = "Sample Buf 2" } }
	state.markToBufMap =
		{ { line = 1, col = 1, buff_name = "Sample Buf 1" }, { line = 2, col = 2, buff_name = "Sample Buf 2" } }

	-- Call the render
	windower.render_mark_list_lines()

	-- Confirm highlight was applied and the contents of buffer are as expected
	luaunit.assertEquals(#vim.api.nvim_buf_get_extmarks(buf, -1, 0, -1, { details = true }), 1)
	luaunit.assertEquals(
		vim.api.nvim_buf_get_lines(buf, 0, -1, false),
		{ "1 | 1 | Sample Buf 1", "2 | 2 | Sample Buf 2" }
	)
end

function TestWindower:test_re_render_mark_list_lines()
	-- Create a real buffer
	local buf = vim.api.nvim_create_buf(false, true)

	-- Set up the state to render the first time.
	state.markBufHandle = buf
	state.currentMarkHandle = 2
	state.marks =
		{ { line = 1, col = 1, buff_name = "Sample Buf 1" }, { line = 2, col = 2, buff_name = "Sample Buf 2" } }
	state.markToBufMap =
		{ { line = 1, col = 1, buff_name = "Sample Buf 1" }, { line = 2, col = 2, buff_name = "Sample Buf 2" } }

	-- Call the render
	windower.render_mark_list_lines()

	-- Confirm highlight was applied and the contents of buffer are as expected
	luaunit.assertEquals(#vim.api.nvim_buf_get_extmarks(buf, -1, 0, -1, { details = true }), 1)
	luaunit.assertEquals(
		vim.api.nvim_buf_get_lines(buf, 0, -1, false),
		{ "1 | 1 | Sample Buf 1", "2 | 2 | Sample Buf 2" }
	)

	-- Update the marks to be modified from before
	state.remove_mark(2)
	-- This is normally called as part of the markme.remove_mark method but we have to call it explicitly here to avoid
	-- a dependency cirlce
	windower.remove_highlight(2)

	-- Call the re_render
	windower.re_render_mark_list_lines()

	-- Confirm the updates are applied
	luaunit.assertEquals(#vim.api.nvim_buf_get_extmarks(buf, -1, 0, -1, { details = true }), 1)
	luaunit.assertEquals(vim.api.nvim_buf_get_lines(buf, 0, -1, false), { "1 | 1 | Sample Buf 1" })
end

function TestWindower:test_windower_closes_window()
	-- Create a real buffer
	local buf = vim.api.nvim_create_buf(false, true)

	-- Set up the state as it would be for when a window close is called
	state.markBufHandle = buf
	state.bufNumToLineNumMap =
		{ { line = 1, col = 1, buff_name = "Sample Buf 1" }, { line = 2, col = 2, buff_name = "Sample Buf 2" } }
	state.selectedRow = 2

	-- Call the close
	windower.close_window()

	-- Confirm the state was reset and the window has a new buffer handle
	luaunit.assertEquals(state.bufNumToLineNumMap, {})
	luaunit.assertEquals(state.selectedRow, nil)
	luaunit.assertNotEquals(state.markBufHandle, buf)
end

return TestWindower
