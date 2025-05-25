# Test Suite
This plugin comes with a test suite that can be ran but will required some dependencies to be installed first. Run the
following commands to set up the project for testing:
```bash
sudo apt-get install luarocks
cd mark-me.nvim
luarocks install luaunit --tree=.luarocks
luarocks install luacov --tree=.luarocks
```
