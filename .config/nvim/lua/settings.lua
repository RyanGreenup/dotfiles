------------------------------------------------------------
-- Neovim Settings -----------------------------------------
------------------------------------------------------------

------------------------------------------------------------
-- Aliases for Vim Commands---------------------------------
------------------------------------------------------------


local map = vim.api.nvim_set_keymap -- set global keymap
local cmd = vim.cmd -- execute Vim commands
local exec = vim.api.nvim_exec -- execute Vimscript
local fn = vim.fn -- call Vim functions
local g = vim.g -- global variables
local opt = vim.opt -- global/buffer/windows-scoped options

-----------------------------------------------------------
-- General
-----------------------------------------------------------

g.mapleader = ' ' -- change leader to a comma
opt.mouse = 'a' -- enable mouse support
opt.clipboard = 'unnamedplus' -- copy/paste to system clipboard
opt.swapfile = false -- don't use swapfile
cmd [[
      imap jk <Esc>              " Get jk for Esc
      let g:markdown_folding=1   " Default Markdown Folding
      ]] --

-----------------------------------------------------------
-- Neovim UI
-----------------------------------------------------------
opt.number = true -- show line number
opt.showmatch = true -- highlight matching parenthesis
opt.foldmethod = 'indent' -- enable folding (default 'foldmarker')
opt.colorcolumn = '80' -- line lenght marker at 80 columns
opt.splitright = true -- vertical split to the right
opt.splitbelow = true -- horizontal split to the bottom
opt.ignorecase = true -- ignore case letters when search
opt.smartcase = true -- ignore lowercase for the whole pattern
opt.linebreak = true -- wrap on word boundary
opt.autoread = true -- Automatically reload files
cmd [[ set modelineexpr ]] -- See vim modeline vulnerability 2019

-- remove whitespace on save
cmd [[au BufWritePre * :%s/\s\+$//e]]


-- highlight on yank
exec([[
    augroup YankHighlight
      autocmd!
      autocmd TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=700}
    augroup end
  ]], false)


-----------------------------------------------------------
-- Memory, CPU
-----------------------------------------------------------
opt.hidden = true -- enable background buffers
opt.history = 100 -- remember n lines in history
opt.lazyredraw = true -- faster scrolling
opt.synmaxcol = 240 -- max column for syntax highlight

-----------------------------------------------------------
-- Colorscheme
-----------------------------------------------------------
opt.termguicolors = true -- enable 24-bit RGB colors
cmd [[colorscheme dracula ]]

-----------------------------------------------------------
-- Tabs, indent
-----------------------------------------------------------
opt.expandtab = true -- use spaces instead of tabs
opt.shiftwidth = 4 -- shift 4 spaces when tab
opt.tabstop = 4 -- 1 tab == 4 spaces
opt.smartindent = true -- autoindent new lines

-- don't auto commenting new lines
cmd [[au BufEnter * set fo-=c fo-=r fo-=o]]

-- remove line length marker for selected filetypes
cmd [[autocmd FileType text,markdown,html,xhtml,javascript setlocal cc=0]]

-- 2 spaces for selected filetypes
cmd [[
  autocmd FileType xml,html,xhtml,css,scss,javascript,lua,yaml setlocal shiftwidth=2 tabstop=2
]]

-----------------------------------------------------------
-- Autocompletion
-----------------------------------------------------------
-- insert mode completion options
opt.completeopt = 'menuone,noselect'

-----------------------------------------------------------
-- Terminal
-----------------------------------------------------------
-- open a terminal pane on the right using :Term
cmd [[command Term :botright vsplit term://$SHELL]]

-- Terminal visual tweaks
--- enter insert mode when switching to terminal
--- close terminal buffer on process exit
cmd [[
    autocmd TermOpen * setlocal listchars= nonumber norelativenumber nocursorline
    autocmd TermOpen * startinsert
    autocmd BufLeave term://* stopinsert
]]

-----------------------------------------------------------
-- Startup
-----------------------------------------------------------
-- disable builtins plugins
local disabled_built_ins = {
  "netrw",
  "netrwPlugin",
  "netrwSettings",
  "netrwFileHandlers",
  "gzip",
  "zip",
  "zipPlugin",
  "tar",
  "tarPlugin",
  "getscript",
  "getscriptPlugin",
  "vimball",
  "vimballPlugin",
  "2html_plugin",
  "logipat",
  "rrhelper",
  "spellfile_plugin",
  "matchit"
}

for _, plugin in pairs(disabled_built_ins) do
  g["loaded_" .. plugin] = 1
end

-- disable nvim intro
opt.shortmess:append "sI"


-----------------------------------------------------------
-- Autocommands
-----------------------------------------------------------

-- https://stackoverflow.com/questions/18948491/running-python-code-in-vim
vim.cmd [[
autocmd FileType python map <buffer>  <F9> :w<CR>:exec      '!python3' shellescape(@%, 1)<CR>
autocmd FileType python imap <buffer> <F9> <esc>:w<CR>:exec '!python3' shellescape(@%, 1)<CR>

autocmd FileType go  map <buffer> <F9> :w<CR>:exec      '!go run' shellescape(@%, 1)<CR>
autocmd FileType go imap <buffer> <F9> <esc>:w<CR>:exec '!go run' shellescape(@%, 1)<CR>

autocmd FileType c  map <buffer> <F9> :w<CR>:exec      '!tcc -run' shellescape(@%, 1)<CR>
autocmd FileType c imap <buffer> <F9> <esc>:w<CR>:exec '!tcc -run' shellescape(@%, 1)<CR>
]]
-- vim.cmd [[ autocmd BufRead,BufNewFile *.c :nmap <F5> :! tcc -run "%"<CR>  ]]
-- vim.cmd [[ autocmd BufRead,BufNewFile *.go :nmap <F5> :! go run "%"<return>  ]]
