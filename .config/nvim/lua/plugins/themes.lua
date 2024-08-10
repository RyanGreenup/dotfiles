local tokyo = {
  "folke/tokyonight.nvim",
  lazy = false,    -- make sure we load this during startup if it is your main colorscheme
  event = "VeryLazy",
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    -- load the colorscheme here
    vim.cmd([[colorscheme tokyonight]])
  end,
}

local rose_pine_opts = {
  variant = "moon",      -- auto, main, moon, or dawn
  dark_variant = "moon", -- main, moon, or dawn
  dim_inactive_windows = true,
  extend_background_behind_borders = true,

  enable = {
    terminal = true,
    legacy_highlights = false, -- Improve compatibility for previous versions of Neovim
    migrations = true,         -- Handle deprecated options automatically
  },

  styles = {
    bold = true,
    italic = true,
    transparency = false,
  },

  groups = {
    border = "muted",
    link = "iris",
    panel = "surface",

    error = "love",
    hint = "iris",
    info = "foam",
    note = "pine",
    todo = "rose",
    warn = "gold",

    git_add = "foam",
    git_change = "rose",
    git_delete = "love",
    git_dirty = "rose",
    git_ignore = "muted",
    git_merge = "iris",
    git_rename = "pine",
    git_stage = "iris",
    git_text = "rose",
    git_untracked = "subtle",

    h1 = "iris",
    h2 = "foam",
    h3 = "rose",
    h4 = "gold",
    h5 = "pine",
    h6 = "foam",
  },

  highlight_groups = {
    Comment = { fg = "foam" },
    -- VertSplit = { fg = "muted", bg = "muted" },
  },
}

local rose_pine = {
  'rose-pine/neovim',
  -- Rose pine can't take opts
  config = function()
    require('rose-pine').setup(rose_pine_opts)
  end
}

return {
  tokyo,
  rose_pine,
  { "EdenEast/nightfox.nvim" },
  { 'https://github.com/bluz71/vim-nightfly-colors' },
  { 'Mofiqul/vscode.nvim' },
  { 'marko-cerovac/material.nvim' },
  { 'ellisonleao/gruvbox.nvim' },
  { 'folke/tokyonight.nvim' },
  { 'Domeee/mosel.nvim' },
  { 'rafamadriz/neon' },
  { 'shaunsingh/moonlight.nvim' },
  { 'catppuccin/nvim' },
  { 'Mofiqul/dracula.nvim' },
}
