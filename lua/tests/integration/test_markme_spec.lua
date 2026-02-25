local utils = require("tests.utils")

describe("mark-me.markme", function()
	local markme
	local state
	local windower

	-- setup / teardown
	before_each(function()
		package.loaded["mark-me.markme"] = nil
		package.loaded["mark-me.state"] = nil
		package.loaded["mark-me.windower"] = nil
		markme = require("mark-me.markme")
		state = require("mark-me.state")
		windower = require("mark-me.windower")
		utils.reset_nvim()
	end)

	describe("markme.go_to_mark", function()
		it("Should go to the mark with autopop off and keep the mark", function()
			-- Create temp buffers to be swapped to on go_to
			local bufOne = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_buf_set_name(bufOne, "Sample Buf 1")
			local bufTwo = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_buf_set_name(bufTwo, "Sample Buf 2")

			-- Create a real buffer
			state.markBufHandle = vim.api.nvim_create_buf(false, true)

			-- Set up the state to render the first time.
			state.selectedRowNumber = 1
			state.marks =
				{ { line = 1, col = 1, buff_name = "Sample Buf 1" }, { line = 2, col = 2, buff_name = "Sample Buf 2" } }

			-- Make the call
			markme.go_to_mark(false)

			-- Confirm the marks has not been modified
			assert.is_same(
				state.marks,
				{ { line = 1, col = 1, buff_name = "Sample Buf 1" }, { line = 2, col = 2, buff_name = "Sample Buf 2" } }
			)
		end)

		it("Should go to the mark with autopop on and remove the mark", function()
			-- Create temp buffers to be swapped to on go_to
			local bufOne = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_buf_set_name(bufOne, "Sample Buf 1")
			local bufTwo = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_buf_set_name(bufTwo, "Sample Buf 2")

			-- Create a real buffer
			state.markBufHandle = vim.api.nvim_create_buf(false, true)

			-- Set up the state to render the first time.
			state.selectedRowNumber = 1
			state.currentMarkHandle = 2
			state.marks =
				{ { line = 1, col = 1, buff_name = "Sample Buf 1" }, { line = 2, col = 2, buff_name = "Sample Buf 2" } }

			-- Make the call
			markme.go_to_mark(true)

			-- Confirm the marks has not been modified
			assert.is_same(state.marks, { { line = 2, col = 2, buff_name = "Sample Buf 2" } })
			assert.is_equal(state.currentMarkHandle, 1)
		end)
	end)
end)
