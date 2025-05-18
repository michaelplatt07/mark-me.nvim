local keybindings = {
	quit = { "n", "q", ':lua require("mark-me.windower").close_window()<CR>', {} },
}

function keybindings.remove()
	require("mark-me.markme").remove_mark()
	require("mark-me.windower").re_render_mark_list_lines()
	vim.api.nvim_command("redraw")
end

function keybindings.update_key_binding(func, custombind) end

function keybindings.map_keys(buf)
	vim.api.nvim_buf_set_keymap(buf, "n", "<leader>o", ':lua require("markme-me.markme").go_to_mark()<CR>', {})
	-- vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", ':lua require("buffer-me.bufferme").open_selected_buffer()<CR>', {})
	-- vim.api.nvim_buf_set_keymap(
	-- 	buf,
	-- 	"n",
	-- 	"f",
	-- 	':lua require("buffer-me.bufferme").set_first_hotswap_from_window()<CR>',
	-- 	{}
	-- )
	-- vim.api.nvim_buf_set_keymap(
	-- 	buf,
	-- 	"n",
	-- 	"s",
	-- 	':lua require("buffer-me.bufferme").set_second_hotswap_from_window()<CR>',
	-- 	{}
	-- )
	-- vim.api.nvim_buf_set_keymap(buf, "n", "g", ':lua require("buffer-me.bufferme").go_to_buffer()<CR>', {})
	vim.api.nvim_buf_set_keymap(buf, "n", "<leader>r", ':lua require("mark-me.keybindings").remove()<CR>', {})
	vim.api.nvim_buf_set_keymap(buf, "n", "q", ':lua require("mark-me.windower").close_window()<CR>', {})
end

return keybindings
