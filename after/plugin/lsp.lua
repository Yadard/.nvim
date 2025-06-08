local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
	-- =============================================================================
	-- ||                      LSP & DIAGNOSTICS KEYMAPS                          ||
	-- =============================================================================

	local opts = { buffer = bufnr, remap = false, silent = true }

	---
	-- Helper function to merge the base 'opts' table with a description.
	-- @param base_opts table The original options table.
	-- @param description string The description for the keymap.
	-- @return table The new, merged options table.
	local function with_desc(base_opts, description)
		-- Create a copy of the base options to avoid modifying it directly.
		local new_opts = vim.deepcopy(base_opts)
		-- Add the description to the new table.
		new_opts.desc = description
		return new_opts
	end

	-- LSP Navigation & Information ---------------------------------------------
	vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, with_desc(opts, "LSP: Go to Definition"))
	vim.keymap.set("n", "gi", function()
		require('telescope.builtin').lsp_implementations()
	end, with_desc(opts, "LSP: Go to Implementation"))
	vim.keymap.set("n", "gr", function()
		require('telescope.builtin').lsp_references()
	end, with_desc(opts, "LSP: List References"))
	vim.keymap.set("n", "Ç", function() vim.lsp.buf.hover() end, with_desc(opts, "LSP: Hover Documentation"))
	vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, with_desc(opts, "LSP: Signature Help"))
	vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end,
		with_desc(opts, "LSP: Search Workspace Symbols"))

	-- Diagnostics ----------------------------------------------------------------
	vim.keymap.set("n", "<leader>vdd", function() vim.diagnostic.open_float() end,
		with_desc(opts, "Diagnostics: Show Line Diagnostics"))
	vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, with_desc(opts, "Diagnostics: Go to Next"))
	vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, with_desc(opts, "Diagnostics: Go to Previous"))

	-- Telescope Diagnostics (Current Buffer) -------------------------------------
	vim.keymap.set('n', '<leader>vda', function()
		require('telescope.builtin').diagnostics({ bufnr = bufnr, severity_limit = 'Hint' })
	end, with_desc(opts, 'Diagnostics: List All (Current Buffer)'))

	vim.keymap.set('n', '<leader>vdw', function()
		require('telescope.builtin').diagnostics({ bufnr = bufnr, severity_limit = 'Warning' })
	end, with_desc(opts, 'Diagnostics: List Warnings (Current Buffer)'))

	vim.keymap.set('n', '<leader>vde', function()
		require('telescope.builtin').diagnostics({ bufnr = bufnr, severity_limit = 'Error' })
	end, with_desc(opts, 'Diagnostics: List Errors (Current Buffer)'))

	-- Telescope Diagnostics (Workspace-Wide) -------------------------------------
	vim.keymap.set('n', '<leader>vwa', function()
		require('telescope.builtin').diagnostics({ bufnr = nil, severity_limit = 'Hint' })
	end, with_desc(opts, 'Diagnostics: List All (Workspace)'))

	vim.keymap.set('n', '<leader>vww', function()
		require('telescope.builtin').diagnostics({ bufnr = nil, severity_limit = 'Warning' })
	end, with_desc(opts, 'Diagnostics: List Warnings (Workspace)'))

	vim.keymap.set('n', '<leader>vwe', function()
		require('telescope.builtin').diagnostics({ bufnr = nil, severity_limit = 'Error' })
	end, with_desc(opts, 'Diagnostics: List Errors (Workspace)'))

	-- LSP Code Manipulation ------------------------------------------------------
	vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, with_desc(opts, "LSP: Code Action"))
	vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, with_desc(opts, "LSP: Show References"))
	vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, with_desc(opts, "LSP: Rename Symbol"))
	vim.keymap.set({ 'n', 'x' }, '<leader>vf', function()
		vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
	end, with_desc(opts, "LSP: Format Code"))
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
	ensure_installed = { 'cmake_language_server', 'clang-format', 'codelldb' }
})
require('mason-lspconfig').setup({
	ensure_installed = { 'cmake', 'rust_analyzer', 'clangd', 'arduino_language_server' },
	handlers = {
		lsp_zero.default_setup,
		lua_ls = function()
			local lua_opts = lsp_zero.nvim_lua_ls()
			require('lspconfig').lua_ls.setup(lua_opts)
		end,
		cmake = function()
			local lua_opts = lsp_zero.nvim_lua_ls()
			require('lspconfig').cmake.setup(lua_opts)
		end,
		pyright = function()
			require('lspconfig').pyright.setup({
				-- Use lsp_zero.on_attach for keymaps etc.
				on_attach = lsp_zero.on_attach,
				settings = {
					python = {
						analysis = {
							typeCheckingMode = "strict",
							diagnosticMode = "workspace",
							autoImportCompletions = true,
							-- Example: exclude specific directories from analysis
							exclude = {
								"**/node_modules",
								"**/__pycache__",
								"**/venv",
								"**/.venv",
								"*.csv",
							},
							-- diagnosticMode = "workspace", -- Uncomment to check all files in workspace
						},
						-- Example: specify a custom virtual environment path
						venvPath = "./venv",
					},
				},
			})
		end,
	}
})

local path = {}

path.path_separator = "/"
path.is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win32unix") == 1
if path.is_windows == true then
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
end

local DEFAULT_FQBN = "arduino:avr:uno"


local lspconfig = require('lspconfig')
lspconfig.arduino_language_server.setup {
	on_new_config = function(config, root_dir)
		local p = root_dir .. "/.arduino"
		local f = io.open(p, 'r')
		vim.notify(("%q, %q"):format(p, f == nil))

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
	sources = {
		{ name = 'path' },
		{ name = 'nvim_lsp' },
		{ name = 'nvim_lua' },
	},
	formatting = lsp_zero.cmp_format(),
	mapping = cmp.mapping.preset.insert({
		['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
		['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
		['<C-d>'] = cmp.mapping.scroll_docs(-4), -- Scroll documentation up
		['<C-f>'] = cmp.mapping.scroll_docs(4), -- Scroll documentation down
		['<C-y>'] = cmp.mapping.confirm({ select = true }),
		['<CR>'] = cmp.mapping.confirm({ select = true }),
		['<C-e>'] = cmp.mapping.abort(), -- Close completion
		['<C-Space>'] = cmp.mapping.complete(),
	}),
})

require('lspfuzzy').setup {}
