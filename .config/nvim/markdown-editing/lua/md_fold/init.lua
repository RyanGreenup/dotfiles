local M = {}

local defaults = {
  startup_folded = 'content',
}

---@param opts? { startup_folded?: 'overview'|'content'|'showeverything' }
function M.setup(opts)
  opts = vim.tbl_extend('force', defaults, opts or {})

  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'markdown', 'rmd' },
    group = vim.api.nvim_create_augroup('md_fold', { clear = true }),
    callback = function(ev)
      local wo = vim.wo
      wo.foldmethod = 'expr'
      wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      wo.fillchars = 'fold: '
      wo.foldtext = 'v:lua.require("md_fold.foldtext").foldtext()'

      if opts.startup_folded == 'overview' then
        wo.foldlevel = 0
      elseif opts.startup_folded == 'showeverything' then
        wo.foldlevel = 99
      else
        wo.foldlevel = 1
      end

      local fold_cycle = require('md_fold.fold_cycle')
      vim.keymap.set('n', '<TAB>', fold_cycle.cycle, { buffer = ev.buf, desc = 'Fold cycle' })
      vim.keymap.set('n', '<S-TAB>', fold_cycle.global_cycle, { buffer = ev.buf, desc = 'Global fold cycle' })
    end,
  })
end

return M
