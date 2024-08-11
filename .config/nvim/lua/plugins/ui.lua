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

local fold_cycle = {
  'jghauser/fold-cycle.nvim',
  opts = {},
}

--- Like Vista, side bar with LSP componentes
local outline = {
  "hedyhli/outline.nvim",
  config = function()
    -- Does not supports opts, must use configure
    require("outline").setup({})
    require('keymaps').fold_cycle()
  end,
}

local search_highlighting = { 'kevinhwang91/nvim-hlslens', opts = {} }

local telescope = {
  'nvim-telescope/telescope.nvim',
  config = function()
    require('telescope').load_extension('file_browser')
    -- if the fzf native extension is installed, load it
    if pcall(require, 'telescope._extensions.fzf') then
      require('telescope').load_extension('fzf')
    end


    if pcall(require, 'telescope._extensions.lazy') then
      require("telescope").load_extension "lazy"
    end
    require("telescope").setup({
      pickers = {
        colorscheme = {
          enable_preview = true
        }
      }
    })
    -- require('telescope').load_extension('dap')
  end
}

local native_fzf_build_command = [[
  sh -c '
  set -e
  if command -v cmake &> /dev/null; then
    cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release
    cmake --build build --config Release
    cmake --install build --prefix build
  else
    echo "You need to install cmake to build the fzf native extension"
    echo "Install cmake and then run :Lazy build fzf-native-extension"
    exit 1
  fi
  '
  ]]

local telescope_fzf = {
  'nvim-telescope/telescope-fzf-native.nvim',
  build = native_fzf_build_command
}

local lualine = {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'kyazdani42/nvim-web-devicons', lazy = false },
  config = function()
    require("lualine").setup({
      sections = {
        lualine_x = { { require("lazy.status").updates, cond = require("lazy.status").has_updates, color = { fg = "#ff9e64" }, }, },
        lualine_c = { { 'filename', path = 1, } }
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

return {
  neotree,
  floating_term,
  which_key,
  git_signs,
  bookmarks,
  flash,
  fold_cycle,
  outline,
  lualine,
  search_highlighting,
  colorbuddy,
  indent_blankline,
  focus,
  -- telescope
  telescope,
  telescope_fzf,
  { "nvim-telescope/telescope-file-browser.nvim" },
  { 'https://github.com/kyazdani42/nvim-web-devicons' },
  { 'https://github.com/camgraff/telescope-tmux.nvim' },

  { 'nvim-telescope/telescope-file-browser.nvim' },
  { 'https://github.com/camgraff/telescope-tmux.nvim' },
  { 'https://github.com/kyazdani42/nvim-web-devicons' },
  { 'nvim-telescope/telescope-symbols.nvim' },
  { 'nvim-telescope/telescope-file-browser.nvim' },
  { 'tsakirist/telescope-lazy.nvim' },
}
