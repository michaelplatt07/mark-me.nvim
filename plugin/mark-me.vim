if exists("g:loaded_mark-me")
    finish
endif
let g:loaded_markme = 1

let s:lua_rocks_deps_loc =  expand("<sfile>:h:r") . "/../lua/mark-me/deps"
exe "lua package.path = package.path .. ';" . s:lua_rocks_deps_loc . "/lua-?/init.lua'"

command! -nargs=0 MarkMeAdd lua require("mark-me").add_mark()
command! -nargs=0 MarkMeOpen lua require("mark-me").open_window()
