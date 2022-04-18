  ------------------------------------------------------------
  -- Aliases for Vim Commands---------------------------------
  ------------------------------------------------------------


  local map = vim.api.nvim_set_keymap  -- set global keymap
  local cmd = vim.cmd     				-- execute Vim commands
  local exec = vim.api.nvim_exec 	-- execute Vimscript
  local fn = vim.fn       				-- call Vim functions
  local g = vim.g         				-- global variables
  local opt = vim.opt         		-- global/buffer/windows-scoped options




g.vimtex_view_method = 'zathura'
-- g.vimtex_view_general_options = '--unique file:@pdf\#src:@line@tex'

cmd [[ syntax enable ]]

cmd [[autocmd BufEnter *.tex :map <leader>v  :VimtexCompile<CR> ]]
