local state = require("mark-me.state")
local keybindings = {
	quit = {
		mode = "n",
		key = "q",
		func = ':lua require("mark-me.windower").close_window()<CR>',
	},
	go_to = { mode = "n", key = "o", func = ':lua require("mark-me.markme").go_to_mark()<CR>' },
	move_up = { mode = "n", key = "u", func = ':lua require("mark-me.keybindings").move_mark_up()<CR>' },
	move_down = { mode = "n", key = "d", func = ':lua require("mark-me.keybindings").move_mark_down()<CR>' },
	remove_mark = { mode = "n", key = "r", func = ':lua require("mark-me.keybindings").remove()<CR>' },
}

function keybindings.remove()
	require("mark-me.markme").remove_mark()
	require("mark-me.windower").re_render_mark_list_lines()
	vim.api.nvim_command("redraw")
end

function keybindings.move_mark_up()
	require("mark-me.markme").move_mark_up()
	require("mark-me.windower").re_render_mark_list_lines()
	vim.api.nvim_command("redraw")
	-- TODO(map) Keep the cursor's current position or move it to the position of the buffer that got moved
end

function keybindings.move_mark_down()
	require("mark-me.markme").move_mark_down()
	require("mark-me.windower").re_render_mark_list_lines()
	vim.api.nvim_command("redraw")
	-- TODO(map) Keep the cursor's current position or move it to the position of the buffer that got moved
end

function keybindings.update_key_binding(func, custombind)
	keybindings[func].key = custombind
end

function keybindings.map_keys(buf)
	vim.api.nvim_buf_set_keymap(buf, keybindings.go_to.mode, keybindings.go_to.key, keybindings.go_to.func, {})
	vim.api.nvim_buf_set_keymap(buf, keybindings.move_up.mode, keybindings.move_up.key, keybindings.move_up.func, {})
	vim.api.nvim_buf_set_keymap(
		buf,
		keybindings.move_down.mode,
		keybindings.move_down.key,
		keybindings.move_down.func,
		{}
	)
	vim.api.nvim_buf_set_keymap(
		buf,
		keybindings.remove_mark.mode,
		keybindings.remove_mark.key,
		keybindings.remove_mark.func,
		{}
	)
	vim.api.nvim_buf_set_keymap(buf, keybindings.quit.mode, keybindings.quit.key, keybindings.quit.func, {})
end

return keybindings
