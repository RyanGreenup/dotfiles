--- Orgmark — org-mode-style editing for Markdown in Neovim.
--- Main entry point. Call `require('orgmark').setup(opts)` to initialize.
local config = require('orgmark.config')

local M = {}

--- Set up orgmark with optional user configuration.
--- Creates a FileType autocmd that configures folding, keymaps,
--- and display settings for markdown buffers.
---@param opts? table  User configuration overrides (see config.lua for defaults)
function M.setup(opts)
  local cfg = config.setup(opts)

  vim.api.nvim_create_autocmd('FileType', {
    pattern = cfg.filetypes,
    group = vim.api.nvim_create_augroup('orgmark', { clear = true }),
    callback = function(ev)
      -- Set up folding for this buffer
      local folding = require('orgmark.folding')
      folding.setup(ev.buf, cfg)

      -- Set up all keymaps (folding, headings, lists, etc.)
      require('orgmark.keymaps').setup(ev.buf)

      -- Enable conceal for link display
      vim.wo.conceallevel = 2
      vim.wo.concealcursor = 'nc'
    end,
  })
end

return M
