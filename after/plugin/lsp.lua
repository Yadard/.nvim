local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
<<<<<<< HEAD
    local opts = { buffer = bufnr, remap = false }
    lsp_zero.buffer_autoformat()

    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "gi", function() vim.lsp.buf.implementation() end, opts)
    vim.keymap.set("n", "Ç", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
    vim.keymap.set({ 'n', 'x' }, '<leader>vf', function()
        vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
    end, opts)
end)

lsp_zero.format_on_save({
    format_opts = {
        async = false,
        timeout_ms = 10000,
    },
    servers = {
        ['tsserver'] = { 'javascript', 'typescript' },
        ['rust_analyzer'] = { 'rust' },
        ['clang-format'] = { 'c++' }
    }
})

require('mason').setup({
    ensure_installed = { 'clang-format', 'codelldb' }
})
require('mason-lspconfig').setup({
    ensure_installed = { 'tsserver', 'rust_analyzer', 'clangd', 'arduino_language_server' },
    handlers = {
        lsp_zero.default_setup,
        lua_ls = function()
            local lua_opts = lsp_zero.nvim_lua_ls()
            require('lspconfig').lua_ls.setup(lua_opts)
        end,
    }
=======
	local opts = { buffer = bufnr, remap = false }
	lsp_zero.buffer_autoformat()

	vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
	vim.keymap.set("n", "Ç", function() vim.lsp.buf.hover() end, opts)
	vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
	vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
	vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
	vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
	vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
	vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
	vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
	vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
	vim.keymap.set({ 'n', 'x' }, '<leader>vf', function()
		vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
	end, opts)
end)

lsp_zero.format_on_save({
	format_opts = {
		async = false,
		timeout_ms = 10000,
	},
	servers = {
		['tsserver'] = { 'javascript', 'typescript' },
		['rust_analyzer'] = { 'rust' },
		['clang-format'] = { 'c++' }
	}
})

require('mason').setup({
	ensure_installed = { 'clang-format', 'codelldb' }
})
require('mason-lspconfig').setup({
	ensure_installed = { 'tsserver', 'rust_analyzer', 'clangd', 'arduino_language_server' },
	handlers = {
		lsp_zero.default_setup,
		lua_ls = function()
			local lua_opts = lsp_zero.nvim_lua_ls()
			require('lspconfig').lua_ls.setup(lua_opts)
		end,
	}
>>>>>>> 71f0e4acdf935415e815d7e7add4d20b1e7ffbde
})

local path = {}

path.path_separator = "/"
path.is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win32unix") == 1
if path.is_windows == true then
<<<<<<< HEAD
    path.path_separator = "\\"
end

path.path_join = function(...)
    local args = { ... }
    if #args == 0 then
        return ""
    end

    local all_parts = {}
    if type(args[1]) == "string" and args[1]:sub(1, 1) == path.path_separator then
        all_parts[1] = ""
    end

    for _, arg in ipairs(args) do
        arg_parts = path.split(arg, M.path_separator)
        vim.list_extend(all_parts, arg_parts)
    end
    return table.concat(all_parts, path.path_separator)
=======
	path.path_separator = "\\"
end

path.path_join = function(...)
	local args = { ... }
	if #args == 0 then
		return ""
	end

	local all_parts = {}
	if type(args[1]) == "string" and args[1]:sub(1, 1) == path.path_separator then
		all_parts[1] = ""
	end

	for _, arg in ipairs(args) do
		arg_parts = path.split(arg, M.path_separator)
		vim.list_extend(all_parts, arg_parts)
	end
	return table.concat(all_parts, path.path_separator)
>>>>>>> 71f0e4acdf935415e815d7e7add4d20b1e7ffbde
end

local DEFAULT_FQBN = "arduino:avr:uno"


local lspconfig = require('lspconfig')
lspconfig.arduino_language_server.setup {
<<<<<<< HEAD
    on_new_config = function(config, root_dir)
        local p = root_dir .. "/.arduino"
        local f = io.open(p, 'r')
        vim.notify(("%q, %q"):format(p, f == nil))
=======
	on_new_config = function(config, root_dir)
		local p = root_dir .. "/.arduino"
		local f = io.open(p, 'r')
		vim.notify(("%q, %q"):format(p, f == nil))
>>>>>>> 71f0e4acdf935415e815d7e7add4d20b1e7ffbde

		if f == nil then
			vim.notify(("Could not find which FQBN to use in %q. Defaulting to %q."):format(p, DEFAULT_FQBN))
			fqbn = DEFAULT_FQBN
		else
			fqbn = io.read(p)
			vim.notify(("Could find which FQBN to use in %q. Using to %q."):format(p, fqbn))
			io.close(f)
		end
		config.cmd = {
			"arduino-language-server",
			"-cli-config", "~/.config/Arduino/arduino-cli.yaml",
			"-fqbn",
			fqbn
		}
	end
}

local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }

cmp.setup({
<<<<<<< HEAD
    sources = {
        { name = 'path' },
        { name = 'nvim_lsp' },
        { name = 'nvim_lua' },
    },
    formatting = lsp_zero.cmp_format(),
    mapping = cmp.mapping.preset.insert({
        ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
        ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
        ['<C-y'] = cmp.mapping.confirm({ select = true }),
        ['<C-Space>'] = cmp.mapping.complete(),
    }),
})

require('lspfuzzy').setup {}
=======
	sources = {
		{ name = 'path' },
		{ name = 'nvim_lsp' },
		{ name = 'nvim_lua' },
	},
	formatting = lsp_zero.cmp_format(),
	mapping = cmp.mapping.preset.insert({
		['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
		['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
		['<C-y'] = cmp.mapping.confirm({ select = true }),
		['<C-Space>'] = cmp.mapping.complete(),
	}),
	completion = {
		completeopt = 'menu,menuone,noinsert'
	}
})
>>>>>>> 71f0e4acdf935415e815d7e7add4d20b1e7ffbde
