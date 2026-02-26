# Mark Me Plugin
A simple plugin for managing marks within buffers in NeoVim.

## Features
The plugin is designed to offer the ability to track marks to be able to be easily jump between within NeoVim. To that 
end, there are a few key functions that can be connected in an `init.lua` file for easy use:
Below is a list of commands that are exposed as features for the plugin:
| Command | Functionality |
|---------|---------------|
| `MarkMeAdd` | Adds the position of the cursor and buffer as a mark to be tracked |
| `MarkMeOpen` | Opens the markme managment window |
| `MarkMeGoForward` | Moves to the next mark in the list |
| `MarkMeGoBack` | Moves to the previous mark in the list and pops the mark from the list if `autopop` is enabled |
| `MarkMeGoBackNoPop` | Like `MarkMeGoback` except will never pop regardless of flag |

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
Below is a list of keybindings that are set by default to the scope of the preview windows created by the plugin:
| Mode | Binding | Functionality |
|------|---------|---------------|
| `n` | `q` | Closes the plugin window |
| `n` | `o` | Goes the currently highlighted mark |
| `n` | `g` | Go to the seleted mark and do no pop no matter the setting |
| `n` | `u` | Moves the makr up the list of marks |
| `n` | `d` | Moves the mark down the list of marks |
| `n` | `r` | Removes the mark from the list |

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

## Plugin Use
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

This plugin comes with a test suite that can be ran but will required some dependencies to be installed first. The plugin
will need luarock installed in some way: 
```bash
sudo apt-get install luarocks
```
For the purposes of keeping depdencies separate, the required rocks can be installed locally at the root level of the plugin:
```bash
cd preview-me.nvim
luarocks install busted --tree=.luarocks
luarocks install luacov --tree=.luarocks
```
The plugin will also need `plenary.nvim` in the same directory as the root of this plugin to be able to run integration
tests. Then test can be ran with the `Makefile` with any of the commands listed.

### Feature Requests/Bugs
If you find a bug or have a request for a feature feel free to add them in GitHub under the issue tracker
