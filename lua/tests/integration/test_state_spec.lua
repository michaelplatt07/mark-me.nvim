local utils = require("tests.utils")

describe("mark-me.state", function()
	local state

	-- setup / teardown
	before_each(function()
		package.loaded["mark-me.state"] = nil
		state = require("mark-me.state")
		utils.reset_nvim()
	end)

	describe("state.init_required_buffers", function()
		it("Should initialze a new buffer if currently nil", function()
			assert.is_nil(state.markBufHandle)

			state.init_required_buffers()
			assert.is_not_nil(state.markBufHandle)
		end)

		it("Should return the currnt buffer if not currently nil", function()
			local buf = vim.api.nvim_create_buf(true, false)
			state.markBufHandle = buf
			state.init_required_buffers()
			assert.is_equal(state.markBufHandle, buf)
		end)
	end)
end)
