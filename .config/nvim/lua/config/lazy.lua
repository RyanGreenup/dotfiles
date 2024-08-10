local map = vim.api.nvim_set_keymap
local default_opts = { noremap = true, silent = true }

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
    'onsails/lspkind.nvim',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/cmp-nvim-lsp-signature-help',
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

-- Snippets
use { 'dcampos/nvim-snippy', dependencies = { 'honza/vim-snippets' },
  config = function() require('config/snippy') end }

use { 'is0n/fm-nvim' }
use({
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
    -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
  },
  config = function()
    require("neo-tree").setup({
      -- I disabled this and re-enabled netrw In favour of stevearc/oil.nvim
      --   hijack_netrw_behavior = "open_current", -- netrw disabled, opening a directory opens neo-tree
    })
  end
})


-- Tree Sitter
use({
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  config = function()
    require 'nvim-treesitter.configs'.setup({
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
    })
  end
})


-- Debugging / DAP

use { "rcarriga/nvim-dap-ui",
  dependencies = {
    "mfussenegger/nvim-dap",
    "nvim-neotest/nvim-nio",
    "mfussenegger/nvim-dap-python",
    "theHamsta/nvim-dap-virtual-text",
    "nvim-telescope/telescope-dap.nvim"
  },
  config = function()
    require("dapui").setup()
    require("nvim-dap-virtual-text").setup({ enabled = true })
    require("dap-python").setup("~/.local/share/virtualenvs/debugpy/bin/python")

    local map = vim.api.nvim_set_keymap
    local default_opts = { noremap = true, silent = true }

    map("n", "<F4>", ":lua require('dapui').toggle()<CR>", default_opts)
    map("n", "<F9>", ":lua require('dap').toggle_breakpoint()<CR>", default_opts)

    map("n", "<F5>", ":lua require('dap').continue()<CR>", default_opts)
    map("n", "<F10>", ":lua require('dap').step_over()<CR>", default_opts)
    map("n", "<F11>", ":lua require('dap').step_into()<CR>", default_opts)
    map("n", "<F23>", ":lua require('dap').step_out()<CR>", default_opts) -- Shift+F11
  end
}

-- Mason to mange LSP servers
use({
  "neovim/nvim-lspconfig",
  -- #+START_Navbuddy
  -- These dependencies are actually for Navbuddy which wires into
  -- the LSP. Bit of a hack, but it works.
  dependencies = {
    "SmiteshP/nvim-navbuddy",
    dependencies = {
      "SmiteshP/nvim-navic",
      "MunifTanjim/nui.nvim"
    },
    opts = { lsp = { auto_attach = true } }
    -- #+END_Navbuddy
  }
})




use { 'williamboman/mason-lspconfig.nvim',
  dependencies = { 'williamboman/mason.nvim' },
  config = function()
    require("mason").setup()
    require("mason-lspconfig").setup {
      ensure_installed = { "lua_ls", "rust_analyzer", "pylsp", "pyright", "bashls", "marksman", "dockerls" },
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
    { "rcarriga/nvim-notify",   lazy = false }, -- this is used by my which-key.lua
    { "echasnovski/mini.icons", lazy = false },
  },
  opts = function()
    return {
      preset = "modern"
    }
  end
})

use {
  'lewis6991/gitsigns.nvim', lazy = false, dependencies = { 'nvim-lua/plenary.nvim' },
  config = function() require('gitsigns').setup() end
}

-- File Managers
use {
  'stevearc/oil.nvim',
  opts = {},
  -- Optional dependencies
  dependencies = { "nvim-tree/nvim-web-devicons" },
}

-- Bookmarks
use {
  "otavioschwanck/arrow.nvim",
  opts = {
    show_icons = true,
    leader_key = '\\',           -- Recommended to be a single key
    buffer_leader_key = '<F12>', -- Per Buffer Mappings
  }
}

-- Comments
use {
  'numToStr/Comment.nvim',
  opts = {
    -- add any options here
  },
  lazy = false,
}

-- Lightspeed, like easy motion
use { 'ggandor/leap.nvim', config = function()
  require('leap').add_default_mappings()
  -- require('leap').leap { target_windows = { vim.fn.win_getid() } }
end }

-- Flash.nvim
use {
  "folke/flash.nvim",
  event = "VeryLazy",
  ---@type Flash.Config
  opts = {},
  -- stylua: ignore
  keys = {
    { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
    { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
    { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
    { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
  },
}


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



use {
  'MeanderingProgrammer/markdown.nvim',
  name = 'render-markdown', -- Only needed if you have another plugin named markdown.nvim
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('render-markdown').setup({
      -- Configure whether Markdown should be rendered by default or not
      start_enabled = false
    })
  end,
}

use {
  'AckslD/nvim-FeMaco.lua',
  config = 'require("femaco").setup()',
}

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

use({ 'TabbyML/vim-tabby' })

-- packer.nvim
-- use({
--   "robitx/gp.nvim",
--   config = function()
--     require("gp").setup()
--
--     -- or setup with your own config (see Install > Configuration in Readme)
--     -- require("gp").setup(config)
--
--     -- shortcuts might be setup here (see Usage > Shortcuts in Readme)
--   end,
-- })

-- use {
--   'huggingface/llm.nvim',
--   config = function()
--     local llm = require('llm')
--
--     llm.setup({
--       api_token = nil,                 -- cf Install paragraph
--       model = "phi3:latest", -- the model ID, behavior depends on backend
--       backend = "ollama",         -- backend ID, "huggingface" | "ollama" | "openai" | "tgi"
--       url = "http://localhost:11434/api",                       -- the http url of the backend
--       tokens_to_clear = { "<|endoftext|>" }, -- tokens to remove from the model's output
--       -- parameters that are added to the request body, values are arbitrary, you can set any field:value pair here it will be passed as is to the backend
--       request_body = {
--         parameters = {
--           max_new_tokens = 60,
--           temperature = 0.2,
--           top_p = 0.95,
--         },
--       },
--       -- set this if the model supports fill in the middle
--       fim = {
--         enabled = true,
--         prefix = "<fim_prefix>",
--         middle = "<fim_middle>",
--         suffix = "<fim_suffix>",
--       },
--       debounce_ms = 150,
--       accept_keymap = "<Insert>",
--       dismiss_keymap = "<Del>",
--       tls_skip_verify_insecure = false,
--       -- llm-ls configuration, cf llm-ls section
--       lsp = {
--         bin_path = nil,
--         host = nil,
--         port = nil,
--         cmd_env = nil, -- or { LLM_LOG_LEVEL = "DEBUG" } to set the log level of llm-ls
--         version = "0.5.3",
--       },
--       tokenizer = nil,               -- cf Tokenizer paragraph
--       context_window = 1024,         -- max number of tokens for the context window
--       enable_suggestions_on_startup = true,
--       enable_suggestions_on_files = "*", -- pattern matching syntax to enable suggestions on specific files, either a string or a list of strings
--       disable_url_path_completion = false, -- cf Backend
--     })
--   end
-- }

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
use { 'liuchengxu/vista.vim',
  config = function()
    -- local map = vim.api.nvim_set_keymap
    -- local default_opts = { noremap = true, silent = true }
    -- map('n', '<C-m>', ':Vista!!<CR>', default_opts)
  end
}
-- Outline is Basically Vista with better LSP
use {
  "hedyhli/outline.nvim",
  config = function()
    -- Example mapping to toggle outline
    vim.keymap.set("n", "<C-m>", "<cmd>Outline<CR>",
      { desc = "Toggle Outline" })

    require("outline").setup {
      -- Your setup opts here (leave empty to use defaults)
    }
  end,
}

-- Quarto ######################################################################

-- Quarto

if vim.fn.has('nvim-0.10.0') == 1 then
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
end




-- Aesthetics ..................................................................
use {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'kyazdani42/nvim-web-devicons', lazy = false }, config = function()
  require("lualine").setup({
    sections = {
      lualine_x = { { require("lazy.status").updates, cond = require("lazy.status").has_updates, color = { fg = "#ff9e64" }, }, },
      lualine_c = { { 'filename', path = 1, } }
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
use('rose-pine/neovim')
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

for _, theme in ipairs({
  "EdenEast/nightfox.nvim",
  'https://github.com/bluz71/vim-nightfly-colors',
  'Mofiqul/vscode.nvim',
  'marko-cerovac/material.nvim',
  'ellisonleao/gruvbox.nvim',
  'folke/tokyonight.nvim',
  'Domeee/mosel.nvim',
  'rafamadriz/neon',
  'shaunsingh/moonlight.nvim',
  'catppuccin/nvim',
  'Mofiqul/dracula.nvim',
  -- 'protesilaos/tempus-themes-vim',
}) do
  use({ theme, lazy = false })
end

-- Additional Syntax ...........................................................
use { 'https://github.com/meatballs/vim-xonsh' }




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

use { 'kevinhwang91/nvim-bqf' }

use { 'SmiteshP/nvim-navbuddy' }


use {
  'kristijanhusak/vim-dadbod-ui',
  dependencies = {
    { 'tpope/vim-dadbod',                     lazy = true },
    { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
  },
  cmd = {
    'DBUI',
    'DBUIToggle',
    'DBUIAddConnection',
    'DBUIFindBuffer',
  },
  init = function()
    -- Your DBUI configuration
    vim.g.db_ui_use_nerd_fonts = 1
  end,
}


use {
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  opts = {
    yazi_floating_window_winblend = 0.1,
  },
  keys = {
    -- 👇 in this section, choose your own keymappings!
    {
      "<leader>-",
      function()
        require("yazi").yazi()
      end,
      desc = "Open the file manager",
    },
    {
      -- Open in the current working directory
      "<leader>cw",
      function()
        require("yazi").yazi(nil, vim.fn.getcwd())
      end,
      desc = "Open the file manager in nvim's working directory",
    },
  },
  ---@type YaziConfig
  opts = {
    -- if you want to open yazi instead of netrw, see below for more info
    open_for_directories = false,
  },
}

use { 'dhruvasagar/vim-table-mode' }

use { 'nvim-focus/focus.nvim', version = '*', opts = { autoresize = { enable = true } } }


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
