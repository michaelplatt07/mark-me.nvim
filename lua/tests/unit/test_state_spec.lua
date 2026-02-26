local utils = require("tests.utils")

describe("mark-me.state", function()
	local state

	-- setup / teardown
	before_each(function()
		package.loaded["mark-me.state"] = nil
		state = require("mark-me.state")
	end)

	describe("state.has_dup", function()
		it("Should return false for an empty marks table", function()
			assert.is_false(state.has_dup(1, 1, "Sample"))
		end)

		it("Should return false for an entry not in the marks table", function()
			state.marks = { { line = 0, col = 0, buff_name = "Sample" } }
			assert.is_false(state.has_dup(1, 1, "Other"))
		end)

		it("Should return true for an etnry in the marks table", function()
			state.marks = { { line = 0, col = 0, buff_name = "Sample" } }
			assert.is_true(state.has_dup(0, 0, "Sample"))
		end)
	end)

	describe("state.add_mark", function()
		it("Should add the non-dupe entry to the table since the table is empty", function()
			state.add_mark(1, 1, "Sample")
			assert.is_same(state.marks, { { line = 1, col = 1, buff_name = "Sample" } })
			assert.is_equal(state.currentMarkHandle, 1)
		end)

		it("Should add the non-dupe entry since it isn't in the table", function()
			state.marks = { { line = 0, col = 0, buff_name = "Other" } }
			state.currentMarkHandle = 1
			state.add_mark(1, 1, "Sample")
			assert.is_same(
				state.marks,
				{ { line = 0, col = 0, buff_name = "Other" }, { line = 1, col = 1, buff_name = "Sample" } }
			)
			assert.is_equal(state.currentMarkHandle, 2)
		end)

		it("Should not at the duplicated entry to the list", function()
			state.marks = { { line = 1, col = 1, buff_name = "Sample" } }
			state.currentMarkHandle = 1
			state.add_mark(1, 1, "Sample")
			assert.is_same(state.marks, { { line = 1, col = 1, buff_name = "Sample" } })
			assert.is_equal(state.currentMarkHandle, 1)
		end)
	end)

	describe("state.remove_mark", function()
		it("Successfully remove the mark", function()
			state.add_mark(1, 1, "Sample")
			state.add_mark(2, 2, "Other")
			assert.is_same(
				state.marks,
				{ { line = 1, col = 1, buff_name = "Sample" }, { line = 2, col = 2, buff_name = "Other" } }
			)
			assert.is_equal(state.currentMarkHandle, 2)

			state.remove_mark(1)

			assert.is_same(state.marks, { { line = 2, col = 2, buff_name = "Other" } })
			assert.is_equal(state.currentMarkHandle, 1)
		end)
	end)

	describe("state.move_mark_up", function()
		it("Should move the mark up because there is space to do it", function()
			state.add_mark(1, 1, "Sample")
			state.add_mark(2, 2, "Other")
			assert.is_same(
				state.marks,
				{ { line = 1, col = 1, buff_name = "Sample" }, { line = 2, col = 2, buff_name = "Other" } }
			)

			state.move_mark_up(2)

			assert.is_same(
				state.marks,
				{ { line = 2, col = 2, buff_name = "Other" }, { line = 1, col = 1, buff_name = "Sample" } }
			)
		end)

		it("Should not move the mark up because there is no space to do it", function()
			state.add_mark(1, 1, "Sample")
			state.add_mark(2, 2, "Other")
			assert.is_same(
				state.marks,
				{ { line = 1, col = 1, buff_name = "Sample" }, { line = 2, col = 2, buff_name = "Other" } }
			)

			state.move_mark_up(1)

			assert.is_same(
				state.marks,
				{ { line = 1, col = 1, buff_name = "Sample" }, { line = 2, col = 2, buff_name = "Other" } }
			)
		end)

		it("Should move the mark up and decrement the current mark handle", function()
			state.add_mark(1, 1, "Sample")
			state.add_mark(2, 2, "Other")
			state.currentMarkHandle = 1
			assert.is_same(
				state.marks,
				{ { line = 1, col = 1, buff_name = "Sample" }, { line = 2, col = 2, buff_name = "Other" } }
			)

			state.move_mark_up(2)

			assert.is_same(
				state.marks,
				{ { line = 2, col = 2, buff_name = "Other" }, { line = 1, col = 1, buff_name = "Sample" } }
			)
			assert.is_equal(state.currentMarkHandle, 2)
		end)
	end)

	describe("state.move_mark_down", function()
		it("Should move the mark down because there is space to do it", function()
			state.add_mark(1, 1, "Sample")
			state.add_mark(2, 2, "Other")
			assert.is_same(
				state.marks,
				{ { line = 1, col = 1, buff_name = "Sample" }, { line = 2, col = 2, buff_name = "Other" } }
			)

			state.move_mark_down(1)

			assert.is_same(
				state.marks,
				{ { line = 2, col = 2, buff_name = "Other" }, { line = 1, col = 1, buff_name = "Sample" } }
			)
		end)

		it("Should not move the mark down because there is no space to do it", function()
			state.add_mark(1, 1, "Sample")
			state.add_mark(2, 2, "Other")
			assert.is_same(
				state.marks,
				{ { line = 1, col = 1, buff_name = "Sample" }, { line = 2, col = 2, buff_name = "Other" } }
			)

			state.move_mark_down(2)

			assert.is_same(
				state.marks,
				{ { line = 1, col = 1, buff_name = "Sample" }, { line = 2, col = 2, buff_name = "Other" } }
			)
		end)

		it("Should move the mark down and increment the current mark handle", function()
			state.add_mark(1, 1, "Sample")
			state.add_mark(2, 2, "Other")
			state.currentMarkHandle = 1
			assert.is_same(
				state.marks,
				{ { line = 1, col = 1, buff_name = "Sample" }, { line = 2, col = 2, buff_name = "Other" } }
			)

			state.move_mark_down(1)

			assert.is_same(
				state.marks,
				{ { line = 2, col = 2, buff_name = "Other" }, { line = 1, col = 1, buff_name = "Sample" } }
			)
			assert.is_equal(state.currentMarkHandle, 2)
		end)
	end)

	describe("state.pop_mark", function()
		it("Should pop the selected mark off the list of marks and update the current mark handle", function()
			state.add_mark(1, 1, "Sample")
			state.add_mark(2, 2, "Other")
			assert.is_same(
				state.marks,
				{ { line = 1, col = 1, buff_name = "Sample" }, { line = 2, col = 2, buff_name = "Other" } }
			)

			state.pop_mark(1)

			assert.is_same(state.marks, { { line = 2, col = 2, buff_name = "Other" } })
			assert.equal(state.currentMarkHandle, 1)
		end)
	end)
end)
