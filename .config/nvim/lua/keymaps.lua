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
map('i', 'jk', '<Esc>', { noremap = true })

-- don't use arrow keys
map('', '<up>', '<nop>', { noremap = true })
map('', '<down>', '<nop>', { noremap = true })
map('', '<left>', '<nop>', { noremap = true })
map('', '<right>', '<nop>', { noremap = true })

-- fast saving with <leader> and s
map('n', '<C-s>', ':w<CR>', default_opts)
map('i', '<C-x><C-s>', '<C-c>:w<CR>', default_opts)

-- move around splits using Ctrl + {h,j,k,l}
map('n', '<C-h>', '<C-w>h', default_opts)
map('n', '<C-j>', '<C-w>j', default_opts)
map('n', '<C-k>', '<C-w>k', default_opts)
map('n', '<C-l>', '<C-w>l', default_opts)

-----------------------------------------------------------
-- FZF / Telescope Stuff
-----------------------------------------------------------


-- Fuzzy Find stuff
map('n', '<C-p>', '<cmd>Telescope find_files<cr>', default_opts)
-- map('n'	, '<leader><leader>', '<cmd>Telescope commands<cr>'   , default_opts)
map('n', '<M-x>', '<cmd>Telescope commands<cr>', default_opts)
map('n', '<C-x><C-b>', '<cmd>Telescope buffers<cr>', default_opts)
map('n', '<C-x>b', '<cmd>Telescope buffers<cr>', default_opts)
-- Change Directory to File
-- Copy File path
-- Ultisnips (More ergonomic
vim.cmd [[
  let g:UltiSnipsExpandTrigger = '<tab>'
  let g:UltiSnipsJumpForwardTrigger = '<tab>'
  let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'
  let g:UltiSnipsEditSplit="vertical"
]]

-----------------------------------------------------------
-- Applications & Plugins shortcuts:
-----------------------------------------------------------
-- open terminal
map('n', '<C-t>', ':Term<CR>', { noremap = true })
map('t', '<Esc>', '<C-\\><C-n>', { noremap = true })

map('n', '<A-i>', '<CMD>lua require("FTerm").toggle()<CR>', { noremap = true })
map('t', '<A-i>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>', { noremap = true })

-- open help for lsp
map('n', '<leader>hk', ':e +/#mappings ~/.config/nvim/lua/plugins/lsp+cmp.lua<CR>', { noremap = true })

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
vim.cmd [[ autocmd BufEnter *.md :nmap <leader>v :MarkdownPreview<CR> ]]

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

  print("#: ", hnum)
end


IS_SMALL = true
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

function my_autosave()
  vim.cmd [[ :autocmd TextChanged,TextChangedI <buffer> silent write ]]
end
map('n', '<leader>ta', ':lua my_autosave()<CR>', default_opts)

function dokuwiki_headings_list()
  local file = vim.api.nvim_buf_get_name(0)
  local regex = ' \'^=.*=$\' '
  local rg_cmd = "rg -n" .. regex .. file .. " | "

  -- TODO awk would be nicer than sd
  local awk_align = [[awk -F':' '{printf "%3d:%s\n", $0, $2}' | ]]
  local rm_trailing = "sd '=+$' '' | "
  local h1 = [[sd '(\d):======' '$1:#'     | ]]
  local h2 = [[sd '(\d):====='  '$1:.##'    | ]]
  local h3 = [[sd '(\d):===='   '$1:..###'   | ]]
  local h4 = [[sd '(\d):==='    '$1:...####'  | ]]
  local h5 = [[sd '(\d):=='     '$1:....#####' | ]]
  local cmd = rg_cmd .. awk_align .. rm_trailing .. h1 .. h2 .. h3 .. h4 .. h5 .. " dmenu -if -l 80 -b --font=monofur | cut -d ':' -f 1 | tr -d '\n'"

  local f = assert(io.popen(cmd, 'r'))
  local s = tonumber(f:read('*a'))
  f:close()
  vim.api.nvim_win_set_cursor(0, { s, 1 })
  -- vim.api.nvim_set_current_line(s)
end

function Toggle_dark()
  if vim.g.colors_name == "dracula" then
    vim.cmd.colorscheme("morning")
  elseif vim.g.colors_name == "morning" then
    vim.cmd.colorscheme("dracula")
  else
    vim.cmd.colorscheme("default")
  end
end

vim.cmd [[ autocmd BufRead,BufNewFile *.txt  set filetype=dokuwiki ]]
vim.cmd [[ autocmd BufRead,BufNewFile *.txt  :nmap <M-Right> xA<Esc>x0<Esc>  ]]
vim.cmd [[ autocmd BufRead,BufNewFile *.txt  :nmap <M-Left> i=<End>=<Esc>0  ]]
vim.cmd [[ autocmd BufRead,BufNewFile *.txt  :nmap <M-Left> :lua dokuwiki_heading(false)<CR>  ]]
vim.cmd [[ autocmd BufRead,BufNewFile *.txt  :nmap <M-Right> :lua dokuwiki_heading(true)<CR>  ]]
-- Folding
-- https://vim.fandom.com/wiki/Folding
vim.cmd [[ autocmd BufRead,BufNewFile *.txt  :nnoremap <silent> <Tab> @=(foldlevel('.')?'za':"\<Space>")<CR>  ]]
vim.cmd [[ autocmd BufRead,BufNewFile *.txt  :vnoremap <Space> zf<CR>  ]]
map('n', '<leader>tw', ':lua IS_WIDE=toggle_full(IS_WIDE)<CR>', default_opts)
map('n', '<leader>dd', ':lua dokuwiki_headings_list()<CR>', default_opts)
map('n', '<leader>td', ':lua Toggle_dark()<CR>', default_opts)













































