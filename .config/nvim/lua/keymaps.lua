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

-- fast saving with <leader> and s
map('i', '<C-x><C-s>', '<C-c>:w<CR>', default_opts)

-- move around splits using Ctrl + {h,j,k,l}
map('n', '<C-h>', '<C-w>h', default_opts)
map('n', '<C-j>', '<C-w>j', default_opts)
map('n', '<C-k>', '<C-w>k', default_opts)
map('n', '<C-l>', '<C-w>l', default_opts)

-- Resize splits using Alt + {h,j,k,l}
map('n', '<A-h>', '<cmd>:vertical resize -5<CR>', default_opts)
map('n', '<A-l>', '<cmd>:vertical resize +5<CR>', default_opts)
map('n', '<A-k>', '<cmd>:resize +5<CR>', default_opts)
map('n', '<A-j>', '<cmd>:resize -5<CR>', default_opts)

-- Docview Plugin
map('n', '<F3>', ':DocsViewToggle<CR>', default_opts)

-----------------------------------------------------------
-- Tabs
-----------------------------------------------------------
map('n', '<M-Right>', '<cmd>tabnext<CR>', default_opts)
map('n', '<M-Left>', '<cmd>tabprev<CR>', default_opts)
map('n', '<M-Up>', '<cmd>tabnew<CR>', default_opts)

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
map('n', '<C-n>', '<cmd>Neotree toggle<CR>', default_opts) -- open/close

-- Vista tag-viewer
map('n', '<C-m>', ':Outline<CR>', default_opts) -- open/close


------------------------------------------------------------
-- Markdown stuff
------------------------------------------------------------
map('n', '<C-PageDown>', '<cmd>lua Change_dayplanner_line(-30)<CR>', default_opts)
map('n', '<C-PageUp>', '<cmd>lua Change_dayplanner_line(30)<CR>', default_opts)

vim.cmd [[ autocmd BufEnter *.md :map <f2> :! pandoc -s --katex "%" -o "%".html && chromium "%".html & disown <Enter> <Enter> ]]
vim.cmd [[ autocmd BufEnter *.md :setlocal filetype=markdown ]]
vim.cmd [[ autocmd BufEnter *.md :nmap <leader>v :MarkdownPreview<CR> ]]

vim.cmd [[
    nmap <Leader>meelo :!pandoc -s --self-contained "%" --listings --toc  -H ~/Templates/LaTeX/ScreenStyle.sty --pdf-engine-opt=-shell-escape --citeproc --bibliography $HOME/Sync/Documents/ref.bib -o /tmp/note.pdf ; xdg-open /tmp/note.pdf & disown


    nmap <Leader>meeho :!pandoc -s --self-contained "%"  --toc -H ~/Templates/CSS/gitOrgWrapped.css --citeproc --bibliography $HOME/Sync/Documents/ref.bib  --csl ~/Templates/CSL/nature.csl -o /tmp/note.html ; cat ~/Templates/mathjax >> /tmp/note.html; xdg-open /tmp/note.html

    nmap <Leader>meehom :!pandoc -s --self-contained "%" --mathml --toc -H ~/Templates/CSS/gitOrgWrapped.css --csl ~/Templates/CSL/nature.csl --citeproc --bibliography $HOME/Sync/Documents/ref.bib  -o /tmp/note.html ;  xdg-open /tmp/note.html

]]


-- Femaco Plugin
map('n', "<C-C>'", '<cmd>FeMaco<CR>', default_opts)

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
  local cmd = rg_cmd ..
      awk_align ..
      rm_trailing .. h1 .. h2 .. h3 .. h4 .. h5 .. " dmenu -if -l 80 -b --font=monofur | cut -d ':' -f 1 | tr -d '\n'"

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

-- Copilot
local copilot_enabled = false
function Copilot_toggle()
  copilot_enabled = not copilot_enabled
  if copilot_enabled then
    vim.cmd([[:Copilot enable]])
    print("Copilot Enabled")
  else
    vim.cmd([[:Copilot disable]])
    print("Copilot Disabled")
  end
end

map('n', '<leader>tc', ':lua Copilot_toggle()<CR>', default_opts)
map('i', '<C-k>', '<Esc>:Copilot<CR><C-w>L:lua Make_floating()<CR>', default_opts)
-- A function to take the current window and make it floating
function Make_floating(t)
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win)

  vim.api.nvim_open_win(buf, true,
    { relative = 'editor', row = 3, col = 3, width = 40, height = 60, border = 'single', title = t })

  vim.api.nvim_win_close(win, true)
end

-- https://neovim.io/doc/user/api.html#nvim_open_win%28%29

-- Keybindings for Snippy
vim.cmd [[
imap <expr> <Tab> snippy#can_expand_or_advance() ? '<Plug>(snippy-expand-or-advance)' : '<Tab>'
imap <expr> <S-Tab> snippy#can_jump(-1) ? '<Plug>(snippy-previous)' : '<S-Tab>'
smap <expr> <Tab> snippy#can_jump(1) ? '<Plug>(snippy-next)' : '<Tab>'
smap <expr> <S-Tab> snippy#can_jump(-1) ? '<Plug>(snippy-previous)' : '<S-Tab>'
xmap <Tab> <Plug>(snippy-cut-text)
]]

-- Tabby
-- /home/ryan/.tabby-client/agent/config.toml
vim.g.tabby_trigger_mode = 'manual'
vim.g.tabby_keybinding_accept = '<Tab>'
vim.g.tabby_keybinding_trigger_or_dismiss = '<C-\\>'

-- Modal Keybindings
map('n', '<Up>', '<cmd>lua ModalCommands[Mode][ModalKey.Up]()<CR>', default_opts)
map('n', '<Down>', '<cmd>lua ModalCommands[Mode][ModalKey.Down]()<CR>', default_opts)
map('n', '<Left>', '<cmd>lua ModalCommands[Mode][ModalKey.Left]()<CR>', default_opts)
map('n', '<Right>', '<cmd>lua ModalCommands[Mode][ModalKey.Right]()<CR>', default_opts)
-- map('n', 'm', '<cmd>lua ModalCommands[Mode][ModalKey.M]()<CR>', default_opts)
-- map('n', 'p', '<cmd>lua ModalCommands[Mode][ModalKey.P]()<CR>', default_opts)




-- Trailing C-i fix
-- https://github.com/neovim/neovim/issues/20126
map('n', '<C-i>', '<C-i>', { noremap = true })





--------------------------------------------------------------------------------
-- Autocommand Keymaps ---------------------------------------------------------
--------------------------------------------------------------------------------
vim.api.nvim_create_autocmd({ 'FileType' }, {
  pattern = 'markdown',
  callback = function()
    map('n', '<C-CR>', '',
      {
        callback = function()
          require('utils/markdown_headings').insert_subheading_below()
        end,
        noremap = true,
        silent = true,
        desc =
        "Use Treesitter to Insert a Markdown Heading of the right level"
      })
    map('n', '<M-Left>', '',
      {
        callback = function()
          require('utils/markdown_headings').demote_heading()
        end,
        noremap = true,
        silent = true,
        desc =
        "Use Treesitter to demote a Markdown Heading"
      })

    map('n', '<M-Right>', '',
      {
        callback = function()
          require('utils/markdown_headings').promote_heading()
        end,
        noremap = true,
        silent = true,
        desc =
        "Use Treesitter to promote a Markdown Heading"
      })

    map('n', '<M-h>', '',
      {
        callback = function()
          require('utils/markdown_headings').promote_all_headings_below()
        end,
        noremap = true,
        silent = true,
        desc =
        "Use Treesitter to promote a Markdown Heading"
      })

    map('n', '<M-l>', '',
      {
        callback = function()
          require('utils/markdown_headings').demote_all_headings_below()
        end,
        noremap = true,
        silent = true,
        desc =
        "Use Treesitter to promote a Markdown Heading"
      })
  end,
})
