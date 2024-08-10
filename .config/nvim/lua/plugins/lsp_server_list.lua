local M = {}  -- define a table to hold our module

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
  "tsserver",
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

  -- Python Servers
  "pylsp",        -- This is the main one, formatting requires it
  "ruff_lsp",     -- This is like pyright but with less Microsoft + black
  "basedpyright", -- This performs type checking and static analysis
}

-- Return the module table so that it can be required by other scripts
return M
