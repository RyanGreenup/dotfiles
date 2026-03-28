-- Ensure ~/.oxfmtrc.json exists so oxfmt doesn't warn about missing config
local oxfmtrc = vim.fn.expand('~/.oxfmtrc.json')
if vim.fn.filereadable(oxfmtrc) == 0 then
  vim.fn.writefile({ '{ "ignorePatterns": [] }' }, oxfmtrc)
end

return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  keys = {
    {
      "<BS>",
      function() require("conform").format({ async = true }) end,
      desc = "Format file",
    },
  },
  opts = {
    formatters_by_ft = {
      -- Web (oxfmt)
      javascript = { "oxfmt" },
      javascriptreact = { "oxfmt" },
      typescript = { "oxfmt" },
      typescriptreact = { "oxfmt" },
      svelte = { "oxfmt" },
      vue = { "oxfmt" },
      css = { "oxfmt" },
      scss = { "oxfmt" },
      less = { "oxfmt" },
      html = { "oxfmt" },
      json = { "oxfmt" },
      jsonc = { "oxfmt" },
      json5 = { "oxfmt" },
      yaml = { "oxfmt" },
      toml = { "oxfmt" },
      markdown = { "oxfmt" },
      mdx = { "oxfmt" },
      graphql = { "oxfmt" },

      -- Python
      python = { "ruff_format" },

      -- Systems
      rust = { "rustfmt" },
      c = { "clang-format" },
      cpp = { "clang-format" },
      zig = { "zigfmt" },
      odin = { "odinfmt" },

      -- Shell
      sh = { "shfmt" },
      bash = { "shfmt" },

      -- Lua
      lua = { "stylua" },

      -- Typst
      typst = { "typstfmt" },

      -- LaTeX
      tex = { "latexindent" },

      -- Kotlin
      kotlin = { "ktlint" },

      -- SQL
      sql = { "sql_formatter" },

      -- Clojure
      clojure = { "cljfmt" },

      -- Helm
      helm = { "oxfmt" },
    },
    formatters = {
      oxfmt = {
        command = "bunx",
        args = { "oxfmt", "--stdin-filepath", "$FILENAME" },
        stdin = true,
      },
    },
  },
}
