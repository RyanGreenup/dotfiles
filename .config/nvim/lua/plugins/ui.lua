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

local which_key = {
  "folke/which-key.nvim",
  dependencies = {
    { "rcarriga/nvim-notify" }
  },
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

local search_highlighting = { 'kevinhwang91/nvim-hlslens', opts = {} }


local lualine = {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'kyazdani42/nvim-web-devicons', lazy = false },
  config = function()
    require("lualine").setup({
      sections = {
        lualine_x = { { require("lazy.status").updates, cond = require("lazy.status").has_updates, color = { fg = "#ff9e64" }, }, },
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
            local state = ""
            if My_snippy_state ~= nil then
              if My_snippy_state.Mode.latex then
                state = state .. "$$"
              end
            end
            return state
          end,
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

local indent_blankline = {
  'lukas-reineke/indent-blankline.nvim',
  config = function()
    require("ibl").setup()
  end,
}

local colorbuddy = { 'tjdevries/colorbuddy.vim', opts = {} }

--- Automatically resize windows
local focus =
{ 'nvim-focus/focus.nvim', version = '*', opts = { autoresize = { enable = true } } }

local floating_term = {
  "numToStr/FTerm.nvim",
  config = function()
    require('config/fterm')
    require('keymaps').fterm()
  end
}

local noice_opts = {
  lsp = {
    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
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
    "rcarriga/nvim-notify",
  },
  enabled = vim.g.my_use_noice_ui or false,
}

return {
  neotree,
  floating_term,
  which_key,
  git_signs,
  bookmarks,
  flash,
  -- fold_cycle,
  outline,
  lualine,
  search_highlighting,
  colorbuddy,
  indent_blankline,
  focus,
  noice,
}
