local state = require("mark-me.state")
local keybindings = {
	quit = { "n", "q", ':lua require("mark-me.windower").close_window()<CR>', {} },
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

function keybindings.update_key_binding(func, custombind) end

function keybindings.map_keys(buf)
	vim.api.nvim_buf_set_keymap(buf, "n", "<leader>o", ':lua require("mark-me.markme").go_to_mark()<CR>', {})
	vim.api.nvim_buf_set_keymap(buf, "n", "u", ':lua require("mark-me.keybindings").move_mark_up()<CR>', {})
	vim.api.nvim_buf_set_keymap(buf, "n", "d", ':lua require("mark-me.keybindings").move_mark_down()<CR>', {})
	vim.api.nvim_buf_set_keymap(buf, "n", "<leader>r", ':lua require("mark-me.keybindings").remove()<CR>', {})
	vim.api.nvim_buf_set_keymap(buf, "n", "q", ':lua require("mark-me.windower").close_window()<CR>', {})
end

return keybindings
