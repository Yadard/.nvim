-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
	-- Packer can manage itself
	use 'wbthomason/packer.nvim'

	-- Simple plugins can be specified as strings
	use 'rstacruz/vim-closer'

	use {
		'nvim-telescope/telescope.nvim', tag = '0.1.5',
		requires = { { 'nvim-lua/plenary.nvim' } }
	}

	use({ 'rose-pine/neovim', as = 'rose-pine' })

	use('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' })
	use('nvim-treesitter/playground')
	use('theprimeagen/harpoon')
	use('ThePrimeagen/vim-be-good')

	use('mbbill/undotree')
	use('tpope/vim-fugitive')
	use('williamboman/mason.nvim')
	use('williamboman/mason-lspconfig.nvim')
	use('ldelossa/nvim-dap-projects')
	use('jose-elias-alvarez/null-ls.nvim')

	use('neovim/nvim-lspconfig')

	use { 'mfussenegger/nvim-dap' }
	use { 'rcarriga/nvim-dap-ui',
		requires = {
			'mfussenegger/nvim-dap',
			'nvim-neotest/nvim-nio'
		}
	}

	use 'nvim-neotest/nvim-nio'
	use {
		"theHamsta/nvim-dap-virtual-text",
		requires = { "mfussenegger/nvim-dap" },
	}

	use {
		'VonHeikemen/lsp-zero.nvim',
		branch = 'v3.x',
		requires = {
			--- Uncomment these if you want to manage LSP servers from neovim
			-- {'williamboman/mason.nvim'},
			-- {'williamboman/mason-lspconfig.nvim'},

			-- LSP Support
			{ 'neovim/nvim-lspconfig' },
			-- Autocompletion
			{ 'hrsh7th/nvim-cmp' },
			{ 'hrsh7th/cmp-nvim-lsp' },
			{ 'L3MON4D3/LuaSnip' },
		}
	}

	use 'jay-babu/mason-nvim-dap.nvim'
	use('lewis6991/gitsigns.nvim')
	use('ojroques/nvim-lspfuzzy')
end)
