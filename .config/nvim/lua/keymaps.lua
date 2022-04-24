-----------------------------------------------------------
-- Keymaps configuration file: keymaps of neovim
-- and plugins.
-----------------------------------------------------------

local map = vim.api.nvim_set_keymap
local default_opts = { noremap = true, silent = true }

-----------------------------------------------------------
-- Neovim shortcuts:
-----------------------------------------------------------

-- clear search highlighting
map('n', '<leader>c', ':nohl<CR>', default_opts)

-- map Esc to kk
map('i', 'kk', '<Esc>', { noremap = true })

-- don't use arrow keys
map('', '<up>', '<nop>', { noremap = true })
map('', '<down>', '<nop>', { noremap = true })
map('', '<left>', '<nop>', { noremap = true })
map('', '<right>', '<nop>', { noremap = true })

-- fast saving with <leader> and s
map('n', '<leader>s', ':w<CR>', default_opts)
map('i', '<C-x><C-s>', '<C-c>:w<CR>', default_opts)

-- move around splits using Ctrl + {h,j,k,l}
map('n', '<C-h>', '<C-w>h', default_opts)
map('n', '<C-j>', '<C-w>j', default_opts)
map('n', '<C-k>', '<C-w>k', default_opts)
map('n', '<C-l>', '<C-w>l', default_opts)

-- close all windows and exit from neovim
map('n', '<leader>q', ':qa!<CR>', default_opts)

-----------------------------------------------------------
-- FZF / Telescope Stuff
-----------------------------------------------------------


-- Fuzzy Find stuff
map('n', '<leader>/', '<cmd>Telescope live_grep<cr>', default_opts)
map('n', '<leader>ht', '<cmd>Telescope colorscheme<cr>', default_opts)
map('n', '<leader>ff', '<cmd>Telescope find_files<cr>', default_opts)
map('n', '<leader>bp', ':bp<CR>', default_opts)
map('n', '<leader>bn', ':bn<CR>', default_opts)
map('n', '<leader>fp', ':e ~/.config/nvim/init.lua<cr>:cd %:p:h<cr> :cd lua<CR>', default_opts)
map('n', '<leader>ss', '<cmd>Telescope current_buffer_fuzzy_find<cr>', default_opts)
map('n', '<C-p>', '<cmd>Telescope find_files<cr>', default_opts)
-- map('n'	, '<leader><leader>', '<cmd>Telescope commands<cr>'   , default_opts)
map('n', '<M-x>', '<cmd>Telescope commands<cr>', default_opts)
map('n', '<leader>bb', '<cmd>Telescope buffers<cr>', default_opts)
map('n', '<C-x><C-b>', '<cmd>Telescope buffers<cr>', default_opts)
map('n', '<C-x>b', '<cmd>Telescope buffers<cr>', default_opts)
map('n', '<leader>fr', '<cmd>Telescope oldfiles<cr>', default_opts)
map('n', '<leader>fg', '<cmd>Telescope<CR>', default_opts)
map('n', '<leader>fb', '<cmd>Telescope buffers<cr>', default_opts)
map('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', default_opts)
map('n', '<leader>e', '<cmd>Telescope quickfix<cr>', default_opts)
-- Change Directory to File
map('n', '<leader>fcd', '<cmd>:cd %:p:h<cr>', default_opts)
-- Copy File path
map('n', '<leader>fy', '<cmd>:let @+=expand("%:p")<cr>', default_opts) -- Copy File path
map('n', '<leader>fY', '<cmd>:let @+=expand("%")<cr>', default_opts) -- Copy File path

-----------------------------------------------------------
-- Applications & Plugins shortcuts:
-----------------------------------------------------------
-- open terminal
map('n', '<C-t>', ':Term<CR>', { noremap = true })

-- nvim-tree
map('n', '<C-n>', ':NvimTreeToggle<CR>', default_opts) -- open/close
map('n', '<leader>r', ':NvimTreeRefresh<CR>', default_opts) -- refresh
map('n', '<leader>n', ':NvimTreeFindFile<CR>', default_opts) -- search file

-- Vista tag-viewer
map('n', '<C-m>', ':Vista!!<CR>', default_opts) -- open/close


------------------------------------------------------------
-- Markdown stuff
------------------------------------------------------------
vim.cmd [[ autocmd BufEnter *.md :map <f2> :! pandoc -s --katex "%" -o "%".html && chromium "%".html & disown <Enter> <Enter> ]]
vim.cmd [[ autocmd BufEnter *.md :setlocal filetype=markdown ]]

vim.cmd [[
    nmap <Leader>meelo :!pandoc -s --self-contained "%" --listings --toc  -H ~/Templates/LaTeX/ScreenStyle.sty --pdf-engine-opt=-shell-escape --citeproc --bibliography $HOME/Sync/Documents/ref.bib -o /tmp/note.pdf ; xdg-open /tmp/note.pdf & disown


    nmap <Leader>meeho :!pandoc -s --self-contained "%"  --toc -H ~/Templates/CSS/gitOrgWrapped.css --citeproc --bibliography $HOME/Sync/Documents/ref.bib  --csl ~/Templates/CSL/nature.csl -o /tmp/note.html ; cat ~/Templates/mathjax >> /tmp/note.html; xdg-open /tmp/note.html

    nmap <Leader>meehom :!pandoc -s --self-contained "%" --mathml --toc -H ~/Templates/CSS/gitOrgWrapped.css --csl ~/Templates/CSL/nature.csl --citeproc --bibliography $HOME/Sync/Documents/ref.bib  -o /tmp/note.html ;  xdg-open /tmp/note.html

]]

-- autocmd BufEnter *.md :map <f12> :w<cr>:!typora "%" & disown <Enter>
-- autocmd BufEnter *.md :map <Space>fo :w<cr>:!marktext "%" & disown <Enter>
-- autocmd BufEnter *.md :map <Space>foa :w<cr>:!atom "%" & disown <Enter>


------------------------------------------------------------
-- dokuwiki stuff
------------------------------------------------------------
vim.notify = require("notify")
vim.cmd [[ autocmd BufRead,BufNewFile *.txt  set filetype=dokuwiki ]]
vim.cmd [[ autocmd BufRead,BufNewFile *.txt  :nmap <M-Right> xA<Esc>x0<Esc>:lua vim.notify("decreased")<CR>  ]]
vim.cmd [[ autocmd BufRead,BufNewFile *.txt  :nmap <M-Left> i=<End>=<Esc>0  ]]

-- vim.api.nvim_create_autocmd({ event = "FileType", group = "MyGroupName", pattern = "*.txt", callback = function require("notify")("My super important message") end, once = true})
-- vim.api.nvim_create_autocmd({ event = "FileType", group = "MyGroupName", pattern = "*.txt", callback = function require("notify")("My super important message") end, once = true})


vim.notify = require("notify")

function dokuwiki_heading(decrease)
  local pos = vim.api.nvim_win_get_cursor(0)[2]
  local line = vim.api.nvim_get_current_line()


  -- Remove the first and last equal
  if decrease then
    line, _ = line:gsub("=", "", 1)
    line, _ = line:gsub("=$", "", 1)
  else
    line, _ = line:gsub("=", "==", 1)
    line, _ = line:gsub("=$", "==", 1)
  end
  vim.api.nvim_set_current_line(line)

  -- count the number of ==
  local _, c = line:gsub("=", "")
  local hnum = 7 - c / 2

  -- Notify the user of the Heading Number
  vim.notify(tostring(hnum))
  print("#: ", hnum)
end

vim.cmd [[ autocmd BufRead,BufNewFile *.txt  :nmap <M-Left> :lua dokuwiki_heading(false)<CR>  ]]
vim.cmd [[ autocmd BufRead,BufNewFile *.txt  :nmap <M-Right> :lua dokuwiki_heading(true)<CR>  ]]



-- Folding
-- https://vim.fandom.com/wiki/Folding
vim.cmd [[ nnoremap <silent> <Tab> @=(foldlevel('.')?'za':"\<Space>")<CR> ]]
vim.cmd [[ vnoremap <Space> zf ]]

-- TODO Shift+TAB to toggle between open and close


-- TODO Fullscreen use a which.key setup
-- make a toggle
-- set lines=999
-- set columns=999
-- vim.cmd [[ nmap <leader>mf ':set lines=999<CR>:set columns=999<CR>' ]]
vim.cmd [[ nmap <leader>qF ':set lines=90<CR>:set columns=60<CR>' ]]

IS_SMALL=true
function toggle_full(make_big)
    if make_big then
      vim.cmd [[ :set lines=20 ]]
      vim.cmd [[ :set columns=40 ]]
      return false
    else
      vim.cmd [[ :set lines=999 ]]
      vim.cmd [[ :set columns=110 ]]
      return true
    end
end

-- map('n', '<leader>tw', ':set columns=90<CR>', default_opts)
map('n', '<leader>tw', ':lua IS_WIDE=toggle_full(IS_WIDE)<CR>', default_opts)



-- autosave
-- https://stackoverflow.com/questions/17365324/auto-save-in-vim-as-you-type

function my_autosave()
    vim.cmd [[ :autocmd TextChanged,TextChangedI <buffer> silent write ]]
    vim.notify("Autosave Enabled")
end




function dokuwiki_headings_list()
  local file = vim.api.nvim_buf_get_name(0)
  local regex =  ' \'^=.*=$\' '
  local rg_cmd = "rg -n"..regex..file

  local cmd = rg_cmd.." | dmenu -if -l 20 -b --font=monofur | cut -d ':' -f 1 | tr -d '\n'"

  local f = assert(io.popen(cmd, 'r'))
  local s = tonumber(f:read('*a'))
  f:close()
  vim.api.nvim_win_set_cursor(0, {s, 1})
  -- vim.api.nvim_set_current_line(s)
end

map('n', '<leader>dd', ':lua dokuwiki_headings_list()<CR>', default_opts)
