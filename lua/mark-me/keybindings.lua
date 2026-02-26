local state = require("mark-me.state")
local keybindings = {
	quit = {
		mode = "n",
		key = "q",
	},
	go_to = { mode = "n", key = "o" },
	go_to_no_pop = { mode = "n", key = "g" },
	move_up = { mode = "n", key = "u" },
	move_down = { mode = "n", key = "d" },
	remove_mark = { mode = "n", key = "r" },
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
	vim.keymap.set(keybindings.go_to_no_pop.mode, keybindings.go_to_no_pop.key, function()
		require("mark-me.markme").go_to_mark(false)
	end, { buffer = buf })
	vim.keymap.set(keybindings.go_to.mode, keybindings.go_to.key, function()
		require("mark-me.markme").go_to_mark(state.autopop)
	end, { buffer = buf })
	vim.keymap.set(keybindings.move_up.mode, keybindings.move_up.key, function()
		require("mark-me.markme").move_mark_up()
		require("mark-me.windower").re_render_mark_list_lines()
		vim.api.nvim_command("redraw")
	end, { buffer = buf })
	vim.keymap.set(keybindings.move_down.mode, keybindings.move_down.key, function()
		require("mark-me.markme").move_mark_down()
		require("mark-me.windower").re_render_mark_list_lines()
		vim.api.nvim_command("redraw")
	end, { buffer = buf })
	vim.keymap.set(keybindings.remove_mark.mode, keybindings.remove_mark.key, function()
		require("mark-me.markme").remove_mark()
		require("mark-me.windower").re_render_mark_list_lines()
		vim.api.nvim_command("redraw")
	end, { buffer = buf })
	vim.keymap.set(keybindings.quit.mode, keybindings.quit.key, function()
		require("mark-me.windower").close_window()
	end, { buffer = buf })
end

return keybindings
