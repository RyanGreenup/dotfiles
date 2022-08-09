------------------------------------------------------------
-- Bootstrap Packer
------------------------------------------------------------
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim',
    install_path })
end

return require('packer').startup(function(use)
  -- Include Packages
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- LSP and Treesitter
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate',
    config = function()
      require 'nvim-treesitter.configs'.setup {
        -- If TS highlights are not enabled at all, or disabled via `disable` prop, highlighting will fallback to default Vim syntax highlighting
        highlight = {
          enable = true,

          disable = { 'latex', 'tex' }, -- Remove this to use TS highlighter for some of the highlights (Experimental)
          -- Vimtex highlighting is needed for mathematics with ultisnips though,
          -- otherwise the math environment won't be detected by the math() function
          -- Hence ignore latex environments so it still works.
          additional_vim_regex_highlighting = { 'org' }, -- Required since TS highlighter doesn't support all syntax features (conceal)
        },
        ensure_installed = { 'org' }, -- Or run :TSUpdate org
      }
    end

  }

  -- TODO Autosave
  -- The last autosave package was very unreliabel
  -- Cursor moved around all the time for instance

  -- Misc
  use { 'glacambre/firenvim', run = function() vim.fn['firenvim#install'](0) end }


  -- Use dependency and run lua function after load
  use {
    'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' },
    config = function() require('gitsigns').setup() end
  }

  -- Markdown
  use { 'iamcco/markdown-preview.nvim', run = 'cd app && yarn install', cmd = 'MarkdownPreview' }
  use 'instant-markdown/vim-instant-markdown'
  use { 'nblock/vim-dokuwiki' }

  -- Appearance
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }

  use "lukas-reineke/indent-blankline.nvim"

  use 'tjdevries/colorbuddy.vim'

  -- Notifications
  use { 'https://github.com/rcarriga/nvim-notify' }

  -- Autosave
  use({
    "Pocco81/auto-save.nvim",
    config = function()
      require("auto-save").setup {
        -- your config goes here
        -- or just leave it empty :)
      }
    end,
  })

  -- Themes
  use { 'dracula/vim', as = 'dracula' }

  -- Telescope
  use { 'nvim-telescope/telescope-fzy-native.nvim' }
  use { 'https://github.com/nvim-telescope/telescope-packer.nvim' }
  use {
    'nvim-telescope/telescope.nvim', branch = '0.1.x',
    requires = { {'nvim-lua/plenary.nvim', 'nvim-telescope/telescope-fzy-native.nvim'} },
    config = function ()
      require('telescope').load_extension('fzy_native') -- Requires fzy (not fzf)
      require("telescope").load_extension "packer"
    end
  }

  use { 'nvim-telescope/telescope-symbols.nvim' }

  -- file manager
  use {
    'kyazdani42/nvim-tree.lua',
    requires = {
      'kyazdani42/nvim-web-devicons', -- optional, for file icon
    },
    config = function() require 'nvim-tree'.setup {} end
  }

  -- LSP
  use 'neovim/nvim-lspconfig'

  -- Vista (Jump to LSP issues)
  use 'liuchengxu/vista.vim'


  -- nvim-cmp
  use {
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/nvim-cmp',
    'saadparwaiz1/cmp_luasnip',
    'quangnguyen30192/cmp-nvim-ultisnips'
  }

  -- REPL
  use 'hkupty/iron.nvim'


  -- Scroll Bar
  use 'https://github.com/dstein64/nvim-scrollview'

  -- LaTeX
  use 'lervag/vimtex'

  -- Snippets
  use 'honza/vim-snippets'
  use 'SirVer/ultisnips'

  -- Search Matching
  use 'kevinhwang91/nvim-hlslens'

  -- Programming
  use 'ray-x/go.nvim'

  -- Org Mode
  use { 'nvim-orgmode/orgmode', config = function()
    require('orgmode').setup {}
  end
  }

  -- Which Key
  use 'folke/which-key.nvim'

  -- Lightspeed, like easy motion
  use 'ggandor/lightspeed.nvim'

  -- Fold-Cycle
  use {
    'jghauser/fold-cycle.nvim',
    config = function()
      require('fold-cycle').setup()
      vim.keymap.set('n', '<tab>',
        function() return require('fold-cycle').open() end,
        { silent = true, desc = 'Fold-cycle: open folds' })
      vim.keymap.set('n', '<s-tab>',
        function() return require('fold-cycle').close() end,
        { silent = true, desc = 'Fold-cycle: close folds' })
      vim.keymap.set('n', 'zC',
        function() return require('fold-cycle').close_all() end,
        { remap = true, silent = true, desc = 'Fold-cycle: close all folds' })
    end
  }

  -- Debugging
  use { "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } }

  -- Auto resize windows
  -- Themes
  use {
    'morhetz/gruvbox',
    'tomasr/molokai',
    'sonph/onehalf',
    'gosukiwi/vim-atom-dark',
    'NLKNguyen/papercolor-theme',
    'jacoborus/tender.vim',
    'rakr/vim-one',
    'ayu-theme/ayu-vim',
    'kyoz/purify'
  }

end)
