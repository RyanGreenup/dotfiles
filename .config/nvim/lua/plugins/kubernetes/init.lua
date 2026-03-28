--- Kubernetes YAML LSP support.
--- Provides hover docs, auto-complete, validation, and CRD schema detection
--- for Kubernetes manifests via yamlls + yaml-companion + SchemaStore.
---
--- Files:
---   schemas.lua  - CRD schema definitions for the picker
---   settings.lua - yamlls settings builder (SchemaStore + kubernetes)

return {
  {
    "mosheavni/yaml-companion.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-lua/plenary.nvim",
      "b0o/SchemaStore.nvim",
    },
    ft = { "yaml", "yaml.docker-compose" },
    config = function()
      local cfg = require("yaml-companion").setup({
        -- Auto-detect Kubernetes files by scanning for apiVersion + kind fields
        builtin_matchers = {
          kubernetes = { enabled = true },
          cloud_init = { enabled = true },
        },

        -- CRD schemas available in the picker (open_ui_select / Telescope)
        schemas = require("plugins.kubernetes.schemas"),

        -- yamlls settings
        lspconfig = {
          settings = require("plugins.kubernetes.settings").build(),
        },
      })

      -- Use native vim.lsp API (matches the rest of this config)
      vim.lsp.config("yamlls", cfg)
      vim.lsp.enable("yamlls")
    end,
    keys = {
      {
        "<leader>ys",
        function() require("yaml-companion").open_ui_select() end,
        desc = "YAML: Select schema",
        ft = "yaml",
      },
    },
  },

  -- SchemaStore.nvim: curated catalog of JSON/YAML schemas (lazy-loaded)
  { "b0o/SchemaStore.nvim", lazy = true },
}
