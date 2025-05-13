-- Set the path so local installed rocks can be imported
package.path = ".luarocks/share/lua/5.3/?.lua;" .. package.path
-- Set the path so local modules from the plugin can be imported
package.path = "./lua/?.lua;" .. package.path

local luaunit = require("luaunit")
local markme

-- Mock Vim so we can mock returns on method bindings
vim = {
	api = {},
}
-- End mocking

require("luacov")

TestMarkMe = {}

-- Setting up and tearing down for each test
function TestMarkMe:setup()
	markme = require("mark-me.markme")
end

function TestMarkMe:teardown()
	markme.state.marks = {}
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

	table.insert(markme.state.marks, { line = 0, col = 0, buff_name = "first_buffer" })
	table.insert(markme.state.marks, { line = 1, col = 1, buff_name = "second_buffer" })
	table.insert(markme.state.marks, { line = 2, col = 2, buff_name = "third_buffer" })
	table.insert(markme.state.marks, { line = 3, col = 3, buff_name = "fourth_buffer" })

	luaunit.assertEquals(markme.state.marks[2], { line = 1, col = 1, buff_name = "second_buffer" })
	markme.remove_mark()
	luaunit.assertEquals(markme.state.marks[2], { line = 2, col = 2, buff_name = "third_buffer" })
end

return TestMarkMe
