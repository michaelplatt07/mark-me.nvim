-- Unit tests
local test_state = require("tests.unit.test_state")
local test_markme = require("tests.unit.test_markme")

local luaunit = require("luaunit")

os.exit(luaunit.LuaUnit.run())
