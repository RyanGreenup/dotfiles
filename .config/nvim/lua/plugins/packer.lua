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

          -- [fn_math_highlighting]
          -- disable = { 'latex', 'tex' }, -- Remove this to use TS highlighter for some of the highlights (Experimental)
          additional_vim_regex_highlighting = { 'org' },                   -- Required since TS highlighter doesn't support all syntax features (conceal)
        },
        ensure_installed = { 'org', 'markdown', 'sql', 'python', 'rust' }, -- Or run :TSUpdate org
      }
    end

  }

  -- Misc
  use { 'glacambre/firenvim', run = function() vim.fn['firenvim#install'](0) end }


  -- Use dependency and run lua function after load
  use {
    'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' },
    config = function() require('gitsigns').setup() end
  }

  -- Markdown
  --   use { 'iamcco/markdown-preview.nvim', run = 'cd app && yarn install', cmd = 'MarkdownPreview' }
  use({
    "iamcco/markdown-preview.nvim",
    run = function() vim.fn["mkdp#util#install"]() end,
  })
  use { 'nblock/vim-dokuwiki' }

  -- Appearance
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }

  use {
    'lukas-reineke/indent-blankline.nvim',
    config = function()
      require("ibl").setup()
    end
  }

  use 'tjdevries/colorbuddy.vim'

  -- Notifications
  use { 'https://github.com/rcarriga/nvim-notify' }

  -- Themes
  use { 'dracula/vim', as = 'dracula' }

  -- Telescope

  use { "nvim-telescope/telescope-file-browser.nvim" }
  use { 'https://github.com/kyazdani42/nvim-web-devicons' }
  use { 'https://github.com/camgraff/telescope-tmux.nvim' }
  -- use { 'nvim-telescope/telescope-dap.nvim' }
  -- Use cmake for fzf because the Makefile is GNUisms.
  use { 'nvim-telescope/telescope-fzf-native.nvim',
    run =
    'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' }
  use { 'https://github.com/nvim-telescope/telescope-packer.nvim' }
  use {
    'nvim-telescope/telescope.nvim', branch = '0.1.x',
    requires = { { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope-fzf-native.nvim' } },
    config = function()
      require('telescope').load_extension('file_browser')
      require('telescope').load_extension('fzf') -- Use fzf for BSD compatability
      require("telescope").load_extension "packer"
      -- require('telescope').load_extension('dap')
    end
  }

  use { 'nvim-telescope/telescope-symbols.nvim' }

  -- file manager
  use {
    "nvim-neo-tree/neo-tree.nvim",
    -- branch = "v3.x",
    requires = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    },
    config = function()
      vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])
    end
  }

  -- Automatically get LSP
  use {
    "williamboman/mason.nvim",
    "neovim/nvim-lspconfig",
  }
  use { 'williamboman/mason-lspconfig.nvim',
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup {
        ensure_installed = { "lua_ls", "rust_analyzer", "pylsp", "pyright", "bashls", "spectral", "marksman", "dockerls" },
      }
      -- Also install some basic servers (https://github.com/williamboman/mason-lspconfig.nvim)
      require("mason-lspconfig").setup()
    end
  }

  -- LSP only for the init.lua
  use { 'folke/neodev.nvim' }

  -- Vista (Jump to LSP issues)
  use 'liuchengxu/vista.vim'


  -- nvim-cmp
  use {
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/nvim-cmp',
    'dcampos/cmp-snippy'
  }

  -- REPL
  use 'hkupty/iron.nvim'
  use 'jpalardy/vim-slime'


  -- Scroll Bar
  use 'https://github.com/dstein64/nvim-scrollview'

  -- LaTeX
  use 'lervag/vimtex'

  -- Snippets
  use 'honza/vim-snippets'
  use { 'dcampos/nvim-snippy', config = function()
    require('snippy').setup({
      enable_auto = true,
      -- The Tab Mapping seems not to stick, I set the keybindings in
      -- ~/.config/nvim/lua/keymaps.lua | 209
      -- [fn_vimtex]
      -- expand_options = {
      --   m = function()
      --     return vim.fn["vimtex#syntax#in_mathzone"]() == 1
      --   end,
      --   c = function()
      --     return vim.fn["vimtex#syntax#in_comment"]() == 1
      --   end,
      -- }
    })
  end }
  -- Search Matching
  use {
    'kevinhwang91/nvim-hlslens',
  }

  -- Org Mode
  use { 'nvim-orgmode/orgmode', config = function()
    require('orgmode').setup {}
  end
  }

  -- Which Key
  --[[
  Due to a bug, pin to this commit
  https://github.com/folke/which-key.nvim/issues/330
  --]]
  use({
    "folke/which-key.nvim",
    commit = "9c190ea91939eba8c2d45660127e0403a5300b5a~1"
  })

  -- Lightspeed, like easy motion
  use { 'ggandor/leap.nvim', config = function()
    require('leap').add_default_mappings()
    --   require('leap').leap { target_windows = { vim.fn.win_getid() } }
  end }


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
  --[[
  use { "rcarriga/nvim-dap-ui",
    requires = { "mfussenegger/nvim-dap" },
    config = function()
      require("dapui").setup()
    end
  }
  use { 'https://github.com/Pocco81/dap-buddy.nvim' }
  use { 'theHamsta/nvim-dap-virtual-text' }
  -- Plugins for language specifics
  use {
    'leoluz/nvim-dap-go',
    config = function()
      require('dap-go').setup()
    end
  }
  use { 'https://github.com/mfussenegger/nvim-dap-python' }
  --]]
  use { 'https://github.com/nvim-neotest/neotest' }
  -- task juggler
  use { 'https://github.com/kalafut/vim-taskjuggler' }

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
    'kyoz/purify',
    'protesilaos/tempus-themes-vim'
  }

  --syntax
  use { 'https://github.com/ron-rs/ron.vim' }
  use { 'https://github.com/imsnif/kdl.vim' }

  use { "numToStr/FTerm.nvim" }


  use {
    "danymat/neogen",
    config = function()
      require('neogen').setup {}
    end,
    requires = "nvim-treesitter/nvim-treesitter",
    -- Uncomment next line if you want to follow only stable versions
    -- tag = "*"
  }


  -- Docs View
  use {
    "amrbashir/nvim-docs-view",
    opt = true,
    cmd = { "DocsViewToggle" },
    config = function()
      require("docs-view").setup {
        position = "left",
        height = 60,
      }
    end
  }

  -- Copilot
  use { "https://github.com/github/copilot.vim" }

  -- packer.nvim
  use({
    "robitx/gp.nvim",
    config = function()
      require("gp").setup()

      -- or setup with your own config (see Install > Configuration in Readme)
      -- require("gp").setup(config)

      -- shortcuts might be setup here (see Usage > Shortcuts in Readme)
    end,
  })

  --[[
  use({
    "jackMort/ChatGPT.nvim",
    config = function()
      require("chatgpt").setup()
    end,
    requires = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim"
    }
  })

  use({
    "dpayne/CodeGPT.nvim",
    requires = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
    },
    config = function()
    end
  })
  --]]

  -- Quarto
  use { 'quarto-dev/quarto-nvim',
    requires = {
      'jmbuhr/otter.nvim',
      'neovim/nvim-lspconfig'
    },
    config = function()
      require 'quarto'.setup {
        lspFeatures = {
          enabled = true,
          languages = { 'r', 'python', 'julia' },
          diagnostics = {
            enabled = true,
            triggers = { "BufWrite" }
          },
          completion = {
            enabled = true
          }
        }
      }
    end
  }
end)




--[[
[fn_vimtex] ...................................................................

These expand options allow snippy to detect mathsones from the vimtex
extension [^l180]. This requires the use of vimtex, rather than treesitter though (see [^41757]

[^l180]: https://github.com/dcampos/nvim-snippy/blob/master/doc/snippy.txt#L179C5-L186C6
[^41757]: https://vi.stackexchange.com/questions/41749/vimtexsyntaxin-mathzone-with-tree-sitter-and-texlab/41757#41757

I had to disable this because of some crazy performance issues with texlab

[fn_math_highlighting] ........................................................
Vimtex highlighting is needed for mathematics with ultisnips,
otherwise the math environment won't be detected by the math() function
Hence ignore latex environments so it still works.

Snippy with the Auto and math mode check is way too slow, there's clearly a bug
LuaSnip is way too complex to configure and maintain
UltiSnips is too slow generally and a PITA when moving between Virtual Environments

In the interests of simplicity, I'm going to abandan mathzone snippets and just
configure a set of auto-snippets that are non-ambiguous, it's simpler.
--]]
