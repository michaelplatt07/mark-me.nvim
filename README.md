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

## Installation
If using Lazy, the configuration for the plugin looks like:
```lua
return {
	"michaelplatt07/mark-me.nvim",
	branch = "main",
	config = function()
		local markme = require("mark-me")
		markme.setup({
			autopop = true,
		})
	end,
}
```

The `branch` line is not necessary if the user doesn't desire to specify a particular branch or version. The `autopop`
flag will handle removing a mark from the managed list in the event that it is jumped to as a nice to have feature, 
though not required to run the plugin.

## Keybindings
When inside the window for managing the marks, the default keybindings are available to perform certain actions:
* `o` -> Opens the current mark in the current buffer
* `u` -> Moves the currently selected mark up in the list of ordered marks
* `d` -> Moves the currently selected mark down in the list of ordered marks
* `r` -> Removes the currently selected mark from the list of ordered marks
* `q` -> Closes the manaement window

### Overriding for Custom Keybindings
These bindings can be changed by providing custom key bindings and their associated functions in the `setup` of the 
configuration. The following example overrides the basic functionality of using `q` in normal mode to close the mark 
management window:
```lua
... -- All the setup work
{
    keys = {
        quit = "e",
    }
}
```

The full list of functions that can be overriden are listed below and are bound to normal mode. Currently there is no 
way to change the binding or function associated with the keys:
* quit
* go_to
* move_up
* move_down
* remove

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
File on GitHub at the [link](https://github.com/michaelplatt07/mark-me.nvim/issues)
