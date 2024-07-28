-- Global Settings -------------------------------------------------------------
vim.g.slime_target = "tmux"
vim.g.slime_bracketed_paste = 1
vim.g.slime_preserve_curpos = 0

-- Autocommands ----------------------------------------------------------------
-- Notification Function -------------------------------------------------------
local function notify(filetype, target_pane)
  local message = "Slime: " .. "Detected: " .. filetype .. " using tmux: " .. target_pane
  require('notify')(message)
end
--     Python ------------------------------------------------------------------
vim.api.nvim_create_autocmd({ 'FileType' }, {
  pattern = 'python',
  callback = function()
    local tmux_session = "ipython"
    -- vim.cmd([[ let g:slime_dont_ask_default = 1]])
    -- vim.cmd([[ let b:slime_config = {"socket_name": "default", "target_pane": "ipython"}]])
    vim.b.slime_config = { socket_name = "default", target_pane = tmux_session }
    vim.g.slime_dont_ask_default = 1
    notify('Python', tmux_session)
    -- vim.cmd([[vsplit | terminal tx ipython]])
    -- vim.cmd([[wincmd h]])
  end,
})

-- R --------------------------------------------------------------------------
vim.api.nvim_create_autocmd({ 'FileType' }, {
  pattern = 'r',
  callback = function()
    vim.cmd([[ let g:slime_dont_ask_default = 1]])
    vim.cmd([[ let b:slime_config = {"socket_name": "default", "target_pane": "r"}]])
    notify('R', 'r')
  end,
})

-- Custom Bindings -------------------------------------------------------------
-- Send everything
vim.cmd [[
  nmap <M-S-CR> gg0vG$<Plug>SlimeRegionSend<C-o>zz
]]

-- [ARCHIVE] Zellij ------------------------------------------------------------
--[[
This is the Zellij config, I had some performance issues and
It didn't resize which was annoying
--]]

local zellij_config = [[
let g:slime_default_config = {"session_id": "current", "relative_pane": "right"}

" I needed this to fix ipython (ptpython loses a \n though)
let g:slime_bracketed_paste = 1

" Don't ask for settings, trigger the prompt with :SlimeConfig
" let g:slime_dont_ask_default = 1

" Preserver the cursor position
let g:slime_preserve_curpos = 0

" Don't move the cursor
let g:slime_preserve_curpos = 0



" Change the default bindings
" let g:slime_no_mappings = 1


" These are commented out, consider the ./iron.lua bindings first
" Default is C-c C-c
" C-CR doesn't work in zellij?
" xmap <M-e> <Plug>SlimeRegionSend
" nmap <M-e> <Plug>SlimeParagraphSend
" nmap <c-c>v     <Plug>SlimeConfig
]]

-- vim.cmd(zellij_config)
