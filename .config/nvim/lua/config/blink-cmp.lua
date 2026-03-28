local M = {}

function M.run_setup()
  require("blink.cmp").setup({
    snippets = { preset = "luasnip" },

    keymap = {
      preset = "none",
      ["<C-k>"] = { "scroll_documentation_up", "fallback" },
      ["<C-j>"] = { "scroll_documentation_down", "fallback" },
      ["<C-n>"] = { "select_next", "fallback" },
      ["<C-p>"] = { "select_prev", "fallback" },
      ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-e>"] = { "hide", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
      ["<Tab>"] = { "snippet_forward", "fallback" },
      ["<S-Tab>"] = { "snippet_backward", "fallback" },
    },

    appearance = {
      nerd_font_variant = "mono",
    },

    signature = { enabled = true },

    completion = {
      trigger = { prefetch_on_insert = false },
      ghost_text = { enabled = true },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
      },
      menu = {
        border = "rounded",
        draw = {
          treesitter = { "lsp" },
        },
      },
    },

    fuzzy = {
      sorts = { "exact", "score", "sort_text" },
    },

    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      per_filetype = {
        lua = { inherit_defaults = true, "lazydev" },
      },
      providers = {
        lsp = { fallbacks = { "buffer" } },
        otter = {
          name = "otter",
          module = "blink.compat.source",
        },
        conjure = {
          name = "conjure",
          module = "blink.compat.source",
        },
      },
    },

    cmdline = {
      enabled = true,
      keymap = { preset = "cmdline" },
      sources = { "buffer", "cmdline" },
    },

    term = { sources = { "buffer", "path" } },
  })
end

return M
