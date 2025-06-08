local builtin = require('telescope.builtin')

require('telescope').setup { defaults = {
	file_ignore_patterns = {
		"node_modules",
		".git"
	}
}
}

vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<leader>pg', builtin.git_files, {})
vim.keymap.set('n', '<leader>pb', builtin.buffers, {})
vim.keymap.set('n', '<leader>ps', function()
	builtin.grep_string({ search = vim.fn.input("Grep > ") });
end)
vim.keymap.set('n', '<leader>pc', builtin.commands, {})
vim.keymap.set('n', '<leader>ph', builtin.man_pages, {})
vim.keymap.set('n', '<leader>pw', builtin.lsp_workspace_symbols, {})
vim.keymap.set('n', '<leader>pd', builtin.lsp_document_symbols, {})
