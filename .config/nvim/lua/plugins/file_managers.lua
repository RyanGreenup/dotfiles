local oil = {
  'stevearc/oil.nvim',
  opts = {
    -- Disable netrw hijacking to allow :Nread to work
    default_file_explorer = false,
  },
  -- Optional dependencies
  dependencies = { "nvim-tree/nvim-web-devicons" },
}

local yazi = {
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  opts = {
    yazi_floating_window_winblend = 0.1,
  },
  ---@type YaziConfig
  opts = {
    open_for_directories = false,
  },
  config = function()
    require('keymaps').yazi()
  end
}

return {
  oil,
  yazi,
}
