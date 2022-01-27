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
map('i', 'kk', '<Esc>', {noremap = true})

-- don't use arrow keys
map('', '<up>', '<nop>', { noremap = true })
map('', '<down>', '<nop>', { noremap = true })
map('', '<left>', '<nop>', { noremap = true })
map('', '<right>', '<nop>', { noremap = true })

-- fast saving with <leader> and s
map('n', '<leader>s', ':w<CR>', default_opts)
map('i', '<leader>s', '<C-c>:w<CR>', default_opts)

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
map('n'	, '<leader>f/'     , '<cmd>Telescope live_grep<cr>'  , default_opts)
map('n'	, '<leader>ht'     , '<cmd>Telescope colorscheme<cr>', default_opts)
map('n'	, '<leader>ff'     , '<cmd>Telescope find_files<cr>' , default_opts)
map('n'	, '<leader>fp'     , ':e ~/.config/nvim/init.lua<cr>:cd %:p:h<cr>', default_opts)
map('n'	, '<leader>ss'     , '<cmd>Telescope current_buffer_fuzzy_find<cr>' , default_opts)
map('n'	, '<C-p>'     , '<cmd>Telescope find_files<cr>' , default_opts)
map('n'	, '<leader><leader>', '<cmd>Telescope commands<cr>'   , default_opts)
map('n'	, '<M-x>', '<cmd>Telescope commands<cr>'   , default_opts)
map('n'	, '<leader>bb'     , '<cmd>Telescope buffers<cr>'    , default_opts)
map('n'	, '<C-x><C-b>'     , '<cmd>Telescope buffers<cr>'    , default_opts)
map('n'	, '<C-x>b'         , '<cmd>Telescope buffers<cr>'    , default_opts)
map('n'	, '<leader>fr'     , '<cmd>Telescope oldfiles<cr>'   , default_opts)
map('n'	, '<leader>fg'     , '<cmd>Telescope<CR>'            , default_opts)
map('n'	, '<leader>fb'     , '<cmd>Telescope buffers<cr>'    , default_opts)
map('n'	, '<leader>fh'     , '<cmd>Telescope help_tags<cr>'  , default_opts)
map('n'	, '<leader>e'     , '<cmd>Telescope quickfix<cr>'  , default_opts)
-- Change Directory to File
map('n'	, '<leader>fcd'    , '<cmd>:cd %:p:h<cr>'            , default_opts)
-- Copy File path
map('n'	, '<leader>fy'     , '<cmd>:let @+=expand("%:p")<cr>', default_opts) -- Copy File path
map('n'	, '<leader>fY'     , '<cmd>:let @+=expand("%")<cr>', default_opts) -- Copy File path

-----------------------------------------------------------
-- Applications & Plugins shortcuts:
-----------------------------------------------------------
-- open terminal
map('n', '<C-t>', ':Term<CR>', { noremap = true })

-- nvim-tree
map('n', '<C-n>', ':NvimTreeToggle<CR>', default_opts)       -- open/close
map('n', '<leader>r', ':NvimTreeRefresh<CR>', default_opts)  -- refresh
map('n', '<leader>n', ':NvimTreeFindFile<CR>', default_opts) -- search file

-- Vista tag-viewer
map('n', '<C-m>', ':Vista!!<CR>', default_opts)   -- open/close


------------------------------------------------------------
-- Markdown stuff
------------------------------------------------------------
vim.cmd [[ autocmd BufEnter *.md :map <f2> :! pandoc -s --katex "%" -o "%".html && chromium "%".html & disown <Enter> <Enter> ]]
vim.cmd [[ autocmd BufEnter *.md :setlocal filetype=markdown ]]

vim.cmd[[
    nmap <Leader>meelo :!pandoc -s --self-contained "%" --listings --toc  -H ~/Templates/LaTeX/ScreenStyle.sty --pdf-engine-opt=-shell-escape --citeproc --bibliography $HOME/Sync/Documents/ref.bib -o /tmp/note.pdf ; xdg-open /tmp/note.pdf & disown


    nmap <Leader>meeho :!pandoc -s --self-contained "%"  --toc -H ~/Templates/CSS/gitOrgWrapped.css --citeproc --bibliography $HOME/Sync/Documents/ref.bib  --csl ~/Templates/CSL/nature.csl -o /tmp/note.html ; cat ~/Templates/mathjax >> /tmp/note.html; xdg-open /tmp/note.html

    nmap <Leader>meehom :!pandoc -s --self-contained "%" --mathml --toc -H ~/Templates/CSS/gitOrgWrapped.css --csl ~/Templates/CSL/nature.csl --citeproc --bibliography $HOME/Sync/Documents/ref.bib  -o /tmp/note.html ;  xdg-open /tmp/note.html

]]

-- autocmd BufEnter *.md :map <f12> :w<cr>:!typora "%" & disown <Enter>
-- autocmd BufEnter *.md :map <Space>fo :w<cr>:!marktext "%" & disown <Enter>
-- autocmd BufEnter *.md :map <Space>foa :w<cr>:!atom "%" & disown <Enter>


