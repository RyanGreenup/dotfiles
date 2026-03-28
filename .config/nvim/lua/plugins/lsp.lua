--- LSP for Neovim Lua files
local lazydev = {
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
  },
  { "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
  {                                        -- optional completion source for require statements and module annotations
    "saghen/blink.cmp",
    opts = {
      sources = {
        default = { "lazydev" },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
        },
      },
    },
  },
}

--- Main LSP configuration
local main_lsp = {
  "neovim/nvim-lspconfig",
  dependencies = { "saghen/blink.cmp" },
  config = function()
    require("config/lsp").run_setup()
  end,
}

--- Completion (blink.cmp)
local cmp = {
  "saghen/blink.cmp",
  version = "1.*",
  dependencies = {
    "L3MON4D3/LuaSnip",
    {
      "saghen/blink.compat",
      version = "*",
      lazy = true,
      opts = {},
    },
  },
  config = function()
    require("config/blink-cmp").run_setup()
  end,
}

--- Snippets
local luasnip = {
  "L3MON4D3/LuaSnip",
  version = "v2.*",
  build = "make install_jsregexp",
  dependencies = { "honza/vim-snippets" },
  config = function()
    require("config/luasnip").run_setup()
  end,
}

local function make_treesitter_table(parsers_to_install)
  return {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main', -- Use new main branch API
    lazy = false,    -- Required: cannot lazy-load treesitter
    build = ':TSUpdate',
    init = function()
      -- init runs at startup before plugin loads - safe for autocmds
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
    config = function()
      -- Defer install to ensure plugin is fully loaded
      vim.defer_fn(function()
        local ok, ts = pcall(require, 'nvim-treesitter')
        if ok and ts.install then
          ts.install(parsers_to_install)
        end
      end, 0)
    end
  }
end

local function make_mason_table(ensure_installed)
  return {
    'mason-org/mason-lspconfig.nvim',
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
    },
    opts = {
      ensure_installed = vim.env.NVIM_SKIP_MASON and {} or ensure_installed,
      automatic_enable = false
    }
  }
end



return {
  -- Neovim Config LSP
  lazydev,

  -- LSP
  main_lsp,

  -- Completion
  cmp,

  -- Snippets
  luasnip,

  -- Treesitter
  make_treesitter_table(require('config/treesitter_list').servers),

  -- Mason
  make_mason_table(require('config/lsp_server_list').servers)

}

-- Footnotes

-- [fn_ts_highlight]
-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
-- Using this option may slow down your editor, and you may see some duplicate highlights.
-- Instead of true it can also be a list of languages
-- additional_vim_regex_highlighting = { 'markdown' }
