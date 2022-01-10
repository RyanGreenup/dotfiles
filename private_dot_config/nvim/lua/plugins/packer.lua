------------------------------------------------------------
-- Bootstrap Packer
------------------------------------------------------------
    local fn = vim.fn
    local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
    packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    end

return require('packer').startup(function()
    -- Include Packages
	-- Packer can manage itself
	use 'wbthomason/packer.nvim'

	-- LSP and Treesitter
	use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }

	-- Misc
	use { 'glacambre/firenvim', run = function() vim.fn['firenvim#install'](0) end }


	-- Use dependency and run lua function after load
	use {
	'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' },
	config = function() require('gitsigns').setup() end
	}

	-- Markdown
	use {'iamcco/markdown-preview.nvim', run = 'cd app && yarn install', cmd = 'MarkdownPreview'}
	use 'instant-markdown/vim-instant-markdown'


	-- Appearance
	use {
	'nvim-lualine/lualine.nvim',
	requires = { 'kyazdani42/nvim-web-devicons', opt = true }
	}

         use "lukas-reineke/indent-blankline.nvim"

	use 'tjdevries/colorbuddy.vim'

	    -- Themes
		use {'dracula/vim', as = 'dracula'}

	-- Telescope
	use {
	'nvim-telescope/telescope.nvim',
	requires = { {'nvim-lua/plenary.nvim'} }
	}

	-- file manager
	use {
	    'kyazdani42/nvim-tree.lua',
	    requires = {
	    'kyazdani42/nvim-web-devicons', -- optional, for file icon
	    },
	    config = function() require'nvim-tree'.setup {} end
	}

  -- LSP
  use 'neovim/nvim-lspconfig'


  -- nvim-cmp
  use {
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-cmdline',
  'hrsh7th/nvim-cmp',
'saadparwaiz1/cmp_luasnip',
'quangnguyen30192/cmp-nvim-ultisnips'}

  -- REPL
  use 'hkupty/iron.nvim'


  -- Scroll Bar
  use 'https://github.com/dstein64/nvim-scrollview'

  -- LaTeX
  use 'lervag/vimtex'
  use 'plasticboy/vim-markdown'

  -- Snippets
     use 'SirVer/ultisnips'
     use 'honza/vim-snippets'

  -- Search Matching
      use 'kevinhwang91/nvim-hlslens'

  -- Programming
  use 'ray-x/go.nvim'

  -- OIrg Mode
  use {'nvim-orgmode/orgmode', config = function()
          require('orgmode').setup{}
  end
      }

  -- Themes
  use {
    'morhetz/gruvbox',
    'tomasr/molokai',
    'sonph/onehalf',
    'dracula/dracula-theme',
    'gosukiwi/vim-atom-dark',
    'NLKNguyen/papercolor-theme',
    'jacoborus/tender.vim',
    'rakr/vim-one',
    'ayu-theme/ayu-vim',
    'kyoz/purify'
  }

end)


