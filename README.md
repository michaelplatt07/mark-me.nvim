# Mark Me Plugin
A simple plugin for managing marks within buffers in NeoVim.

## Features
The plugin is designed to offer the ability to track marks to be able to be easily jump between within NeoVim. To that 
end, there are a few key functions that can be connected in an `init.lua` file for easy use:
* `MarkMeAdd` -> Function to add a mark to the list of marks. This adds both the row and column position of the cursor
* `MarkMeOpen` -> Opens the marke managment window
* `MarkMeGoForward` -> Moves to the next mark in the list
* `MarkMeGoBack` -> Moves to the previous mark in the list
* `MarkMePopGoBack` -> Goes back to the previous mark and pops the mark off the list of managed marks

## Configuration
A sample configuration (if you are using Lazy) might look something like this in the `init.lua` file:
```lua
-- Set adding the current cursor to plugin to manage
vim.keymap.set("n", "<leader>ma", ":MarkMeAdd<cr>")
-- Opens up the window for the plugin
vim.keymap.set("n", "<leader>m", ":MarkMeOpen<cr>")

-- Helper function that can be called to add a mark and go to the function definition
function mark_go_to_def()
	vim.cmd("MarkMeAdd")
	vim.lsp.buf.definition()
end

-- Calling the helper function
vim.keymap.set("n", "md", mark_go_to_def)
```

## Test Suite
This plugin comes with a test suite that can be ran but will required some dependencies to be installed first. Run the
following commands to set up the project for testing:
```bash
sudo apt-get install luarocks
cd mark-me.nvim
luarocks install luaunit --tree=.luarocks
luarocks install luacov --tree=.luarocks
```
then the `test.sh` file can be ran to confirm functionality

### Feature Requests/Bugs
File on GitHub at the (link)[https://github.com/michaelplatt07/mark-me.nvim/issues]
