-- See ~/.config/nvim/docs/slime.md for more details

-- Global Settings -------------------------------------------------------------
vim.g.slime_target = "tmux"
vim.g.slime_bracketed_paste = 1
vim.g.slime_preserve_curpos = 0
vim.g.slime_no_mappings = 1
local percent_cell = "# %%"

-- Keymaps --------------------------------------------------------------------
-- local function normal_map(desc, key, func_or_string)
--   local map = vim.api.nvim_set_keymap
--   if type(func_or_string) == 'string' then
--     map('n', key, func_or_string, { noremap = true, silent = true, desc = desc })
--     return
--   else
--     map('n', key, '',
--       {
--         callback = func,
--         noremap = true,
--         silent = true,
--         desc = desc
--       })
--   end
-- end
-- local nmap = function(desc, key, cmd)
--   local map = vim.api.nvim_set_keymap
--   map('n', key, cmd, { noremap = true, silent = true, desc = desc })
-- end

vim.api.nvim_set_keymap('n', '<M-S-CR>', '<Plug>SlimeSendCell', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<S-CR>', '<Plug>SlimeSendLine', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<S-CR>', '<Plug>SlimeParagraphSend', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<S-CR>', '<Plug>SlimeRegionSend', { noremap = true, silent = true })
vim.api.nvim_set_keymap('x', '<S-CR>', '<Plug>SlimeRegionSend', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-M-CR>', '',
  { noremap = true, silent = true, callback = require('utils/slime_utils').slime_send_buffer })
-- See keymaps_auto_markdown.lua for markdown bindings


-- Autocommands ----------------------------------------------------------------
-- Notification Function -------------------------------------------------------
local function notify(filetype, target_pane)
  local message = "Slime: " .. "Detected: " .. filetype .. " using tmux: " .. target_pane
  require('notify')(message)
end

local function configure_slime(filetype, cell_delimiter)
  local tmux_session = require('utils/slime_utils').get_session_name(filetype)
  vim.b.slime_config = { socket_name = "default", target_pane = tmux_session }
  vim.g.slime_dont_ask_default = 1
  vim.b.slime_cell_delimiter = cell_delimiter
  notify(filetype, tmux_session)
end

local function autocmd_slime(filetype)
  -- Add *. before ext
  for i, _ in ipairs(filetype.exts) do
    filetype.exts[i] = "*."..filetype.exts[i]
  end
  vim.api.nvim_create_autocmd({"BufWinEnter"}, {
    pattern = filetype.exts,
    callback = function(ev)
      _ = ev
      configure_slime(filetype.name, percent_cell)
    end,
  })
end

local langs = {
  {name="lua", exts = {"lua"}},
  {name="python", exts = {"py", "python"}},
  {name="rust", exts = {"rs"}},
  {name="julia", exts = {"jl"}},
  {name="bash", exts = {"bash"}},
  {name="sh", exts = {"sh"}},
  {name="fish", exts = {"fish"}},
  {name="r", exts = {"R", "r"}},
}

for _, lang in pairs(langs) do
  autocmd_slime(lang)
  -- print("name: "..lang.name)
  -- for _, ext in ipairs(lang.exts) do
  --   print("    "..ext)
  -- end
end

-- for _, lang in ipairs({ 'lua', 'py', 'python', 'rust', 'julia', 'sh', 'fish', 'jl', 'r' }) do
--   autocmd_slime(lang)
-- end

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
