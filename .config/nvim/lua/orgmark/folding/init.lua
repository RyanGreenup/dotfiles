--- Folding setup for orgmark.
--- Configures buffer/window-local fold options using treesitter-based foldexpr.
local M = {}

--- Set up folding for a specific buffer.
--- Configures foldmethod, foldexpr, foldtext, fillchars, and initial foldlevel.
---@param bufnr number  Buffer number
---@param config table  The merged orgmark configuration (from config.lua)
function M.setup(bufnr, config)
  local wo = vim.wo

  wo.foldmethod = 'expr'
  wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  wo.foldtext = "v:lua.require('orgmark.folding.text').foldtext()"
  wo.fillchars = 'fold: '

  local startup = config.folding.startup_folded
  if startup == 'overview' then
    wo.foldlevel = 0
  elseif startup == 'showeverything' then
    wo.foldlevel = 99
  else
    -- 'content' or any unrecognized value defaults to level 1
    wo.foldlevel = 1
  end
end

return M
