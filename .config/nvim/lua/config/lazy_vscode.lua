--------------------------------------------------------------------------------
-- Bootstrap Lazy Vim ----------------------------------------------------------
--------------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

--------------------------------------------------------------------------------
-- Set the plugins as a table --------------------------------------------------
--------------------------------------------------------------------------------
-- Create a local table + Helper function to hold the plugins
local plugins = {}
local function use(t)
  table.insert(plugins, t)
end
use('folke/lazy.nvim')

-- Lightspeed, like easy motion
use { 'ggandor/leap.nvim', config = function()
  require('leap').add_default_mappings()
  -- require('leap').leap { target_windows = { vim.fn.win_getid() } }
end }


-- Flash.nvim
use {
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

-- Tree Sitter -- needed by flash
use({
  'nvim-treesitter/nvim-treesitter',
  branch = 'main', -- Use new main branch API
  lazy = false,
  build = ':TSUpdate',
  init = function()
    -- init runs at startup before plugin loads - safe for autocmds
    vim.api.nvim_create_autocmd('FileType', {
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
      end,
    })
  end,
  config = function()
    -- Defer install to ensure plugin is fully loaded
    vim.defer_fn(function()
      local ok, ts = pcall(require, 'nvim-treesitter')
      if ok and ts.install then
        ts.install({ 'org', 'markdown', 'sql', 'python', 'rust' })
      end
    end, 0)
  end
})




-- For a list of events see
-- https://neovim.io/doc/user/autocmd.html
local opts = {
  defaults = {
    lazy = false,
  }
}


--------------------------------------------------------------------------------
-- Finally Call the plugin Manager ---------------------------------------------
--------------------------------------------------------------------------------
require("lazy").setup(plugins, opts)

