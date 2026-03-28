--- Orgmark — org-mode-style editing for Markdown in Neovim.
--- Main entry point. Call `require('orgmark').setup(opts)` to initialize.
local config = require('orgmark.config')

local M = {}

--- Set up orgmark with optional user configuration.
--- Creates a FileType autocmd that configures folding, keymaps,
--- and display settings for markdown buffers.
---@param opts? table  User configuration overrides (see config.lua for defaults)
function M.setup(opts)
  -- Pull from the declarative config file when no explicit opts are given.
  if not opts then
    local user_cfg = require('config')
    opts = {
      folding = {
        startup_folded = user_cfg.markdown.startup_folded,
        ellipsis = user_cfg.markdown.fold_ellipsis,
        show_line_count = user_cfg.markdown.fold_show_line_count,
      },
    }
  end
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

      -- Conceal settings from central config
      local md_cfg = require('config').markdown
      vim.wo.conceallevel = md_cfg.conceallevel or 0
      vim.wo.concealcursor = md_cfg.concealcursor or 'nc'
    end,
  })
end

return M
