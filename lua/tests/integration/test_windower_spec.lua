local utils = require("tests.utils")

describe("mark-me.windower", function()
	local windower
	local state

	-- setup / teardown
	before_each(function()
		package.loaded["mark-me.windower"] = nil
		package.loaded["mark-me.state"] = nil
		windower = require("mark-me.windower")
		state = require("mark-me.state")
		utils.reset_nvim()
	end)

	describe("windower.render_mark_list_lines", function()
		it("Should render an empty window with no lines", function()
			-- Create a real buffer
			state.markBufHandle = vim.api.nvim_create_buf(false, true)

			-- Set up the state as it would be for when a render is called and no highlight would be needed
			state.marks = {}

			-- Call the render
			windower.render_mark_list_lines()

			-- Confirm there are no highlights and the contents of buffer are as expected
			assert.is_equal(#vim.api.nvim_buf_get_extmarks(state.markBufHandle, -1, 0, -1, { details = true }), 0)
			assert.is_same(vim.api.nvim_buf_get_lines(state.markBufHandle, 0, -1, false), { "" })
		end)

		it("Should render the lines with the appropriate line highlighted", function()
			-- Create a real buffer
			state.markBufHandle = vim.api.nvim_create_buf(false, true)

			-- Set up the state as it would be for when a a render is called and a highlight should be present
			state.currentMarkHandle = 2
			state.marks =
				{ { line = 1, col = 1, buff_name = "Sample Buf 1" }, { line = 2, col = 2, buff_name = "Sample Buf 2" } }

			-- Call the render
			windower.render_mark_list_lines()

			-- Confirm highlight was applied and the contents of buffer are as expected
			assert.is_equal(#vim.api.nvim_buf_get_extmarks(state.markBufHandle, -1, 0, -1, { details = true }), 1)
			assert.is_same(
				vim.api.nvim_buf_get_lines(state.markBufHandle, 0, -1, false),
				{ "1 | 1 | Sample Buf 1", "2 | 2 | Sample Buf 2" }
			)
		end)
	end)

	describe("windower.re_render_mark_list_lines", function()
		it("Should rerender the new buffer with the new lines and new highlight", function()
			-- Create a real buffer
			state.markBufHandle = vim.api.nvim_create_buf(false, true)

			-- Set up the state to render the first time.
			state.currentMarkHandle = 2
			state.marks =
				{ { line = 1, col = 1, buff_name = "Sample Buf 1" }, { line = 2, col = 2, buff_name = "Sample Buf 2" } }

			-- Call the render
			windower.render_mark_list_lines()

			-- Confirm highlight was applied and the contents of buffer are as expected
			assert.is_equal(#vim.api.nvim_buf_get_extmarks(state.markBufHandle, -1, 0, -1, { details = true }), 1)
			assert.is_same(
				vim.api.nvim_buf_get_lines(state.markBufHandle, 0, -1, false),
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
			assert.is_equal(#vim.api.nvim_buf_get_extmarks(state.markBufHandle, -1, 0, -1, { details = true }), 1)
			assert.is_same(vim.api.nvim_buf_get_lines(state.markBufHandle, 0, -1, false), { "1 | 1 | Sample Buf 1" })
		end)
	end)

	describe("windower.close_window", function()
		it("Should close the window and clean up the state", function()
			-- Create a real buffer
			local buf = vim.api.nvim_create_buf(false, true)

			-- Set up the state as it would be for when a window close is called
			state.markBufHandle = buf
			state.selectedRowNumber = 2

			-- Call the close
			windower.close_window()

			-- Confirm the state was reset and the window has a new buffer handle
			assert.is_nil(state.selectedRowNumber)
			assert.is_not_equal(state.markBufHandle, buf)
		end)
	end)
end)
