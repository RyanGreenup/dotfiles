local M = {} -- define a table to hold our module

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
-- local python_server_choices = {
--   Popups = { 'pylyzer', 'pylsp', 'pyright' },
--   Formatting = { 'ruff', 'pylsp', 'black' },
--   Linting = { 'ruff', 'pyright' },
--   Type_Checking = { 'pylyzer', 'pyright', 'mypy', 'pytype', 'pyre' }
-- }

-- TODO consider creating a config module?
M.servers = {
  "bashls",
  "clangd",
  "clojure_lsp",
  "cmake",
  "csharp_ls",
  "dartls",
  "dockerls",
  "dotls",
  "gopls",
  "java_language_server",
  "jsonls",
  "lua_ls",
  "kotlin_language_server",
  "nimls",
  "quick_lint_js",
  "r_language_server",
  "racket_langserver",
  "rust_analyzer",
  "texlab",
  "ts_ls",
  "stylelint_lsp",
  "vala_ls",
  "vls",
  "zls",
  "ols",
  "spectral",
  "ansiblels",
  "rome",
  "jsonls",
  "html",
  "denols",
  "markdown_oxide", -- 'marksman'
  'qmlls',
  'typst_lsp',

  "basedpyright",
  "ruff",
}

-- Return the module table so that it can be required by other scripts
return M
