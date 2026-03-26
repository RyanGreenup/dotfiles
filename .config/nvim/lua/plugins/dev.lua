--------------------------------------------------------------------------------
-- General ---------------------------------------------------------------------
--------------------------------------------------------------------------------

local comments = {
  "numToStr/Comment.nvim",
  opts = {},
}

--- Annotation Generator
local neogen = {
  "danymat/neogen",
  opts = {},
  dependencies = "nvim-treesitter/nvim-treesitter",
}

local docs_view = {
  "amrbashir/nvim-docs-view",
  opt = true,
  cmd = { "DocsViewToggle" },
  config = function()
    require("docs-view").setup({
      position = "left",
      height = 60,
    })
  end,
}

local neotest = { "https://github.com/nvim-neotest/neotest", opts = {}, dependencies = "nvim-neotest/nvim-nio" }

local bqf = { 'kevinhwang91/nvim-bqf' }

--------------------------------------------------------------------------------
-- Syntax ----------------------------------------------------------------------
--------------------------------------------------------------------------------

local ron = { "https://github.com/ron-rs/ron.vim" }
local kdl = { "https://github.com/imsnif/kdl.vim" }
local xonsh = { "https://github.com/meatballs/vim-xonsh" }

--------------------------------------------------------------------------------
-- REPL ------------------------------------------------------------------------
--------------------------------------------------------------------------------

local iron = {
  "hkupty/iron.nvim",
  config = function()
    require('config/iron')
  end
}
local slime = {
  "jpalardy/vim-slime",
  opts = {},
  config = function()
    require("config/slime")
  end,
}

local quarto = {
  "quarto-dev/quarto-nvim",
  dependencies = {
    "jmbuhr/otter.nvim",
    "neovim/nvim-lspconfig",
  },
  opts = {
    lspFeatures = {
      enabled = true,
      languages = { "r", "python", "julia" },
      diagnostics = {
        enabled = true,
        triggers = { "BufWrite" },
      },
      completion = {
        enabled = true,
      },
    },
  },
}

--------------------------------------------------------------------------------
-- SQL -------------------------------------------------------------------------
--------------------------------------------------------------------------------

local dadbod = {
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


--------------------------------------------------------------------------------
-- LLM -------------------------------------------------------------------------
--------------------------------------------------------------------------------

local copilot = {
  "https://github.com/github/copilot.vim",
  opt = {},
  config = function()
    vim.cmd([[Copilot disable]])
  end
}

local tabby = {
  "TabbyML/vim-tabby",
  config = function()
    -- Fix: vim-tabby calls make_position_params() without position_encoding,
    -- which triggers a deprecation warning on Neovim 0.11+.
    -- Upstream: https://github.com/TabbyML/vim-tabby
    local ok, tabby_lsp = pcall(require, "tabby.lsp.nvim_lsp")
    if not ok then return end

    tabby_lsp.request_inline_completion = function(params)
      local client = vim.lsp.get_clients({ name = "tabby" })[1]
      if client == nil then
        return 0
      end
      local lsp_params = vim.lsp.util.make_position_params(0, client.offset_encoding)
      lsp_params.context = { triggerKind = params.trigger_kind }
      local request_id
      _, request_id = client.request("textDocument/inlineCompletion", lsp_params, function(_, result)
        vim.fn["tabby#lsp#nvim_lsp#CallInlineCompletionCallback"](request_id, result)
      end)
      return request_id
    end
  end,
}

return {
  comments,
  neogen,
  docs_view,
  neotest,
  ron,
  kdl,
  xonsh,
  iron,
  slime,
  quarto,
  copilot,
  tabby,
  bqf,
  dadbod,
}
