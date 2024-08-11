local map = vim.api.nvim_set_keymap
local default_opts = { noremap = true, silent = true }

--------------------------------------------------------------------------------
-- Bootstrap Lazy Vim ----------------------------------------------------------
--------------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-------------------------------------------------------------------------------
-- Set loose plugins as a table -----------------------------------------------
-------------------------------------------------------------------------------
-- Create a local table + Helper function to hold the plugins
local plugins = {}
local function use(t)
  table.insert(plugins, t)
end

-- Add additional plugins like so:
use('folke/lazy.nvim')



--------------------------------------------------------------------------------
-- Finally Call the plugin Manager ---------------------------------------------
--------------------------------------------------------------------------------

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- import your plugins
    { import = "plugins" }, -- [fn_plugins]
    plugins                 -- [fn_loose_plugins]
  },
  checker = { enabled = true },
})




-- Footnotes
-- [fn_plugins]
  -- Plugins are managed under the plugins/ directory with
  -- Additional logic under config/
-- [fn_loose_plugins]
  -- Loose plugins can be quickly and temp added with 'use repo/plugin'
