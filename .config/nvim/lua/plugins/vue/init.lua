--- Vue SFC support.
--- Sets up vue_ls (Volar) in hybrid mode alongside vtsls, which handles
--- TypeScript via @vue/typescript-plugin. vue-goto-definition filters
--- go-to-definition results so you land in source files instead of
--- auto-imports.d.ts or components.d.ts.

local vue_language_server_path = vim.fn.stdpath("data")
  .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"

return {
  -- vue-goto-definition: filter go-to-definition to skip generated files
  {
    "catgoose/vue-goto-definition.nvim",
    event = "BufReadPre",
    opts = {},
  },

  -- vue_ls + vtsls hybrid mode configuration
  {
    "neovim/nvim-lspconfig",
    ft = "vue",
    config = function()
      -- Configure vtsls with the Vue TypeScript plugin
      vim.lsp.config("vtsls", {
        settings = {
          vtsls = {
            tsserver = {
              globalPlugins = {
                {
                  name = "@vue/typescript-plugin",
                  location = vue_language_server_path,
                  languages = { "vue" },
                  configNamespace = "typescript",
                },
              },
            },
          },
        },
        filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
      })

      -- Enable vue_ls (Volar) for CSS/HTML in SFCs
      vim.lsp.enable("vue_ls")
    end,
  },
}
