-- This version helps to ensure there are no issues with exiting early and NeoVim not complaining about a missing
-- runtime or something like that. It does not however, work for running code coverage
-- local root = vim.fn.getcwd()
-- vim.opt.runtimepath:append(root)
--
-- vim.schedule(function()
-- 	-- Integration tests
-- 	require("tests.integration.test_windower")
-- 	require("tests.integration.test_markme")
--
-- 	local luaunit = require("luaunit")
--
-- 	-- os.exit(luaunit.LuaUnit.run())
-- 	local code = luaunit.LuaUnit.run()
-- 	vim.cmd("qa!") -- ensure exit
-- 	os.exit(code)
-- end)

-- Integration tests
require("tests.integration.test_windower")
require("tests.integration.test_markme")

local luaunit = require("luaunit")

os.exit(luaunit.LuaUnit.run())
