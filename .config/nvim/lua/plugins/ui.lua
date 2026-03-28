local neotree =
{
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  opts = {
    hijack_netrw_behavior = "disabled"
  },
  config = function()
    require('keymaps').neotree()
  end
}

local snacks = {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    notifier = { enabled = true },
    terminal = { enabled = true },
    indent   = { enabled = true },
    words    = { enabled = true },
  },
}

local which_key = {
  "folke/which-key.nvim",
  opts = function()
    return {
      preset = "modern"
    }
  end,
  config = function()
    require('config/which-key')
  end
}

local git_signs = {
  'lewis6991/gitsigns.nvim', opts = {}
}

local bookmarks = {
  "otavioschwanck/arrow.nvim",
  opts = {
    show_icons = true,
    leader_key = '\\',           -- Recommended to be a single key
    buffer_leader_key = '<F12>', -- Per Buffer Mappings
  }
}

--- Flash provides jumps like leap using Treesitter
local flash =
{
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

-- local fold_cycle = {
--   'jghauser/fold-cycle.nvim',
--   opts = {},
-- }

--- Like Vista, side bar with LSP componentes
local outline = {
  "hedyhli/outline.nvim",
  config = function()
    -- Does not supports opts, must use configure
    require("outline").setup({})
    -- require('keymaps').fold_cycle()
  end,
}


local lualine = {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'kyazdani42/nvim-web-devicons', lazy = false },
  config = function()
    require("lualine").setup({
      sections = {
        lualine_x = {
          {
            require("plugins.minuet.settings").statusline_daily_cost,
            icon = "🎵",
            color = { fg = "#9ece6a" },
          },
          { require("lazy.status").updates, cond = require("lazy.status").has_updates, color = { fg = "#ff9e64" }, },
        },
        lualine_y = {
          { "progress", separator = " ",                  padding = { left = 1, right = 0 } },
          { "location", padding = { left = 0, right = 1 } },
          function()
            return os.date("%a %d %H:%M")
          end,
        },
        lualine_c = { { 'filename', path = 1, } },
        lualine_a = { "mode",
          function()
            if require("utils/tsutils_math").in_mathzone() then
              return "󰘦"
            else
              return ""
            end
          end
        },
      },
    })
  end
}

--- Automatically resize windows
local focus =
{ 'nvim-focus/focus.nvim', version = '*', opts = { autoresize = { enable = true } } }

local noice_opts = {
  lsp = {
    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      -- cmp.entry.get_documentation removed (was nvim-cmp specific; blink.cmp handles its own docs)
    },
  },
  -- you can enable a preset for easier configuration
  presets = {
    bottom_search = true,         -- use a classic bottom cmdline for search
    command_palette = true,       -- position the cmdline and popupmenu together
    long_message_to_split = true, -- long messages will be sent to a split
    inc_rename = false,           -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = false,       -- add a border to hover docs and signature help
  },
}

local noice = {
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = noice_opts,
  dependencies = {
    -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
    "MunifTanjim/nui.nvim",
    -- OPTIONAL:
    --   `nvim-notify` is only needed, if you want to use the notification view.
    --   If not available, we use `mini` as the fallback
  },
  enabled = vim.g.my_use_noice_ui or false,
}

local autopairs = {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  opts = {},
}

local autotag = {
  "windwp/nvim-ts-autotag",
  event = "InsertEnter",
  opts = {},
}

return {
  neotree,
  snacks,
  which_key,
  git_signs,
  bookmarks,
  flash,
  -- fold_cycle,
  outline,
  lualine,
  focus,
  noice,
  autopairs,
  autotag,
}
