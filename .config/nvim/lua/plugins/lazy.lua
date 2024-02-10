--------------------------------------------------------------------------------
-- Bootstrap Lazy Vim ----------------------------------------------------------
--------------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

--------------------------------------------------------------------------------
-- Set the plugins as a table --------------------------------------------------
--------------------------------------------------------------------------------
-- Create a local table + Helper function to hold the plugins
local plugins = {}
local function use(t)
  table.insert(plugins, t)
end
use('folke/lazy.nvim')

-- Utilities ...................................................................
-- LSP for init.lua
use({
  'folke/neodev.nvim',
  dependencies = { 'neovim/nvim-lspconfig' }
})
-- LSP
use({
  'hrsh7th/nvim-cmp',
  dependencies =
  {
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    {
      'dcampos/cmp-snippy',
      dependencies = { {
        'dcampos/nvim-snippy',
        config = function()
          require('snippy').setup({ enable_auto = true })
        end
      } }
    }

  }
})





-- Tree Sitter
use({
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  config = function()
    require 'nvim-treesitter.configs'.setup {
      -- A list of parser names, or "all" (the five listed parsers should always be installed)
      ensure_installed = { 'org', 'markdown', 'sql', 'python', 'rust' },

      highlight = {
        enable = true,

        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        -- additional_vim_regex_highlighting = { 'markdown' }
      },
    }
  end
})


-- Debugging / DAP
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

-- Mason to mange LSP servers
use({
  "neovim/nvim-lspconfig",
})
use { 'williamboman/mason-lspconfig.nvim',
  dependencies = { 'williamboman/mason.nvim' },
  config = function()
    require("mason").setup()
    require("mason-lspconfig").setup {
      ensure_installed = { "lua_ls", "rust_analyzer", "pylsp", "pyright", "bashls", "spectral", "marksman", "dockerls" },
    }
    -- Also install some basic servers (https://github.com/williamboman/mason-lspconfig.nvim)
    require("mason-lspconfig").setup()
  end
}


-- REPL
use('hkupty/iron.nvim')
use('jpalardy/vim-slime')

use({ 'https://github.com/nvim-neotest/neotest' })

-- Org Mode
use { 'nvim-orgmode/orgmode', config = function()
  require('orgmode').setup {}
end,
}


-- Which key

use({
  "folke/which-key.nvim",
  lazy = false,
  dependencies = {
    { "rcarriga/nvim-notify", lazy = false } -- this is used by my which-key.lua
  }
})

use {
  'lewis6991/gitsigns.nvim', lazy = false, dependencies = { 'nvim-lua/plenary.nvim' },
  config = function() require('gitsigns').setup() end
}

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

use({
  "iamcco/markdown-preview.nvim",
  build = function() vim.fn["mkdp#util#install"]() end,
})
use('lervag/vimtex')
use { 'nblock/vim-dokuwiki' }
use({ 'glacambre/firenvim', build = function() vim.fn['firenvim#install'](0) end })
use({ 'kevinhwang91/nvim-hlslens', })

use { "numToStr/FTerm.nvim" }




use {
  "danymat/neogen",
  config = function()
    require('neogen').setup {}
  end,
  dependencies = "nvim-treesitter/nvim-treesitter",
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

-- syntax
use { 'https://github.com/ron-rs/ron.vim' }
use { 'https://github.com/imsnif/kdl.vim' }

-- Telescope ###################################################################

use { "nvim-telescope/telescope-file-browser.nvim" }
use { 'https://github.com/kyazdani42/nvim-web-devicons' }
use { 'https://github.com/camgraff/telescope-tmux.nvim' }
-- use { 'nvim-telescope/telescope-dap.nvim' }
-- Use cmake for fzf because the Makefile is GNUisms.
local native_fzf_build_command = [[
  sh -c '
  set -e
  if command -v cmake &> /dev/null; then
    cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release
    cmake --build build --config Release
    cmake --install build --prefix build
  else
    echo "You need to install cmake to build the fzf native extension"
    echo "Install cmake and then run :Lazy build fzf-native-extension"
    exit 1
  fi
  '
  ]]
use {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-telescope/telescope-file-browser.nvim',
    'https://github.com/camgraff/telescope-tmux.nvim',
    'https://github.com/kyazdani42/nvim-web-devicons',
    'nvim-telescope/telescope-symbols.nvim',
    'nvim-telescope/telescope-file-browser.nvim',
    'tsakirist/telescope-lazy.nvim',
    'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim',
      build = native_fzf_build_command } },
  config = function()
    require('telescope').load_extension('file_browser')
    -- if the fzf native extension is installed, load it
    if pcall(require, 'telescope._extensions.fzf') then
      require('telescope').load_extension('fzf')
    end

    if pcall(require, 'telescope._extensions.lazy') then
      require("telescope").load_extension "lazy"
    end
    require("telescope").setup({
      pickers = {
        colorscheme = {
          enable_preview = true
        }
      }
    })
    -- require('telescope').load_extension('dap')
  end
}

-- Vista (Jump to LSP issues)
use 'liuchengxu/vista.vim'

-- Quarto ######################################################################

-- Quarto
use { 'quarto-dev/quarto-nvim',
  dependencies = {
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




-- Aesthetics ..................................................................
use {
  'nvim-lualine/lualine.nvim',
  requires = { 'kyazdani42/nvim-web-devicons', lazy = false }, config = function()
  require("lualine").setup({
    sections = {
      lualine_x = {
        {
          require("lazy.status").updates,
          cond = require("lazy.status").has_updates,
          color = { fg = "#ff9e64" },
        },
      },
    },
  })
end
}

use {
  'lukas-reineke/indent-blankline.nvim',
  config = function()
    require("ibl").setup()
  end,
}

use 'tjdevries/colorbuddy.vim'


-- Themes ics ..................................................................
use({
  "folke/tokyonight.nvim",
  lazy = false,    -- make sure we load this during startup if it is your main colorscheme
  event = "VeryLazy",
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    -- load the colorscheme here
    vim.cmd([[colorscheme tokyonight]])
  end,
})
use { 'Mofiqul/dracula.nvim' }
use { 'catppuccin/nvim' }
use { 'shaunsingh/moonlight.nvim' }
use { 'rafamadriz/neon' }
use { 'Domeee/mosel.nvim' }
use { 'folke/tokyonight.nvim' }
use 'ellisonleao/gruvbox.nvim'
use 'marko-cerovac/material.nvim'
use 'Mofiqul/vscode.nvim'
use 'https://github.com/bluz71/vim-nightfly-colors'
-- use { 'tomasr/molokai' }
-- use 'https://github.com/projekt0n/github-nvim-theme'
-- use { 'protesilaos/tempus-themes-vim' }




--------------------------------------------------------------------------------
-- Set any Options as a table --------------------------------------------------
--------------------------------------------------------------------------------

-- For a list of events see
-- https://neovim.io/doc/user/autocmd.html
local opts = {
  defaults = {
    lazy = false,
  }
}


--------------------------------------------------------------------------------
-- Finally Call the plugin Manager ---------------------------------------------
--------------------------------------------------------------------------------
require("lazy").setup(plugins, opts)




--[[
-- Notes ......................................................................
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