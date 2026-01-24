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
  -- NOTE depends on Python3.13 (build in docker while waiting)
  "cmake",
  "dockerls",
  "dotls",
  -- "java_language_server",
  "jsonls",
  "lua_ls",
  "kotlin_language_server",
  -- "nimls",
  "quick_lint_js",
  "r_language_server",
  "rust_analyzer",
  "texlab",
  -- "ts_ls",
  "vtsls", -- This is used by Zed, so probably a safe bet
  "stylelint_lsp",
  -- "vala_ls",
  "zls",
  "ols",
  "ansiblels",
  "qmlls",
  -- "rome",
  "jsonls",
  "html",
  -- "denols",
  "markdown_oxide", -- 'marksman'
  -- "marksman",
  'tinymist', -- typst
  'tailwindcss',

  "basedpyright",
  "ruff",
  "svelte",
  -- jsx (vtsls is default for Zed, so stick with that <https://zed.dev/docs/languages/typescript>)
  -- NOTE MUST NOT have a deno.json anywhere above, it will override current dir
  'vtsls',
  'qmlls',
  'slint_lsp',
  'sqlls',
}

-- Return the module table so that it can be required by other scripts
return M
