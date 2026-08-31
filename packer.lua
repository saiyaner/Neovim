return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  -- Completion
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'saadparwaiz1/cmp_luasnip'
  use 'L3MON4D3/LuaSnip'
  use 'rafamadriz/friendly-snippets'
  use 'Exafunction/codeium.nvim'

  -- Fuzzy finder
  use 'nvim-telescope/telescope.nvim'
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

  -- LSP & Diagnostics
  use 'neovim/nvim-lspconfig'
  use 'lewis6991/gitsigns.nvim'
  use 'folke/trouble.nvim'
  use 'stevearc/dressing.nvim'
  use 'kdheepak/lazygit.nvim'

  -- Editing enhancements
  use 'MagicDuck/grug-far.nvim'
  use 'RRethy/vim-illuminate'
  use 'mbbill/undotree'
  use 'NvChad/nvim-colorizer.lua'
  use 'mg979/vim-visual-multi'
  use 'folke/flash.nvim'
  use 'chentoast/marks.nvim'
  use 'windwp/nvim-autopairs'
  use 'numToStr/Comment.nvim'
  use 'lukas-reineke/indent-blankline.nvim'
  use 'kylechui/nvim-surround'
  use 'windwp/nvim-ts-autotag'
  use 'folke/todo-comments.nvim'

  -- Session management
  use 'folke/persistence.nvim'

  -- UI
  use 'goolord/alpha-nvim'
  use 'folke/which-key.nvim'

  -- Treesitter (required for many plugins)
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use 'nvim-treesitter/nvim-treesitter-textobjects'
end)