------------------------------------------------------------
-- Neovim Settings -----------------------------------------
------------------------------------------------------------

------------------------------------------------------------
-- Aliases for Vim Commands---------------------------------
------------------------------------------------------------


local map = vim.api.nvim_set_keymap -- set global keymap
local cmd = vim.cmd                 -- execute Vim commands
local exec = vim.api.nvim_exec      -- execute Vimscript
local fn = vim.fn                   -- call Vim functions
local g = vim.g                     -- global variables
local opt = vim.opt                 -- global/buffer/windows-scoped options

-----------------------------------------------------------
-- General
-----------------------------------------------------------

g.mapleader = ' '             -- change leader to a comma
vim.api.nvim_set_keymap('i', '<M-Space>', '<Esc><leader>', { noremap = true })
opt.mouse = 'a'               -- enable mouse support
opt.clipboard = 'unnamedplus' -- copy/paste to system clipboard
opt.swapfile = false          -- don't use swapfile
cmd [[
      imap jk <Esc>              " Get jk for Esc
      let g:markdown_folding=1   " Default Markdown Folding
      ]] --

-- This is required for some FUSE and NFS stuff, see <https://github.com/RyanGreenup/joplin_sqlite_fuse/commit/6d03b93a26f645c76129b809161a34bddf2452b7>
vim.cmd([[set backupcopy=yes]])

--------------------------------------------------------------------------------
-- Custom Vim Commands ---------------------------------------------------------
--------------------------------------------------------------------------------
-- Markdown Journal Insert Nav Table
require('utils/insert_journal_table').setup()

-----------------------------------------------------------
-- Neovim UI
-----------------------------------------------------------
opt.number = true          -- show line number
opt.showmatch = true       -- highlight matching parenthesis
opt.foldlevelstart = 99    -- Open everything up at first
opt.colorcolumn = '80'     -- line lenght marker at 80 columns
opt.splitright = true      -- vertical split to the right
opt.splitbelow = true      -- horizontal split to the bottom
opt.ignorecase = true      -- ignore case letters when search
opt.smartcase = true       -- ignore lowercase for the whole pattern
opt.linebreak = true       -- wrap on word boundary
opt.autoread = true        -- Automatically reload files
opt.relativenumber = true  -- Relative numbers
cmd [[ set modelineexpr ]] -- See vim modeline vulnerability 2019

-- Folding
opt.foldmethod = "expr" -- fold based on Treesitter Expression
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- opt.foldtext = "v:lua.vim.treesitter.foldtext()" -- This is null if undefined, use autocommand if needed
opt.foldlevel = 99                   -- Start with everything unfolded
opt.fillchars:append({ fold = " " }) -- Don't show fold icons

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
opt.hidden = true     -- enable background buffers
opt.history = 100     -- remember n lines in history
opt.lazyredraw = true -- faster scrolling
opt.synmaxcol = 240   -- max column for syntax highlight

-----------------------------------------------------------
-- Colorscheme
-----------------------------------------------------------
opt.termguicolors = true -- enable 24-bit RGB colors
cmd [[colorscheme rose-pine ]]

-----------------------------------------------------------
-- Tabs, indent
-----------------------------------------------------------
opt.expandtab = true   -- use spaces instead of tabs
opt.shiftwidth = 4     -- shift 4 spaces when tab
opt.tabstop = 4        -- 1 tab == 4 spaces
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
  --  "netrw",
  --  "netrwPlugin",
  --  "netrwSettings",
  --  "netrwFileHandlers",
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
-- Misc Plugins
-----------------------------------------------------------
require('hlslens').setup()

-----------------------------------------------------------
-- Language Translation
-----------------------------------------------------------

function Line_to_esperanto()
  -- Read the current line as a string
  local cl = vim.api.nvim_get_current_line()
  -- Combine into a shell command
  local command = "argos-translate -f en -t eo '" .. cl .. "'"
  -- Run the shell command and read the output as a string
  local out = io.popen(command):read()
  -- Replace the line with the translation
  vim.api.nvim_set_current_line(out)
end

map('n', '<M-r>', ':lua Line_to_esperanto() <CR>', { noremap = true })


-----------------------------------------------------------
-- Task Management Stuff
-----------------------------------------------------------
vim.cmd [[
:command InsertTaskTags :r ! cd ~/Agenda/Agenda_Maybe && cat (fd -t f) | rg "^:([\w\s/]+):" -r '$1' -o | sort -u<CR>
]]

-----------------------------------------------------------
-- Neoray GUI
-----------------------------------------------------------


vim.cmd [[

if exists('g:neoray')
  NeoraySet CursorAnimTime 0.05
  NeoraySet Transparency 0.95
  NeoraySet ContextButton Say\ Hello :echo "Hello World!"
  NeoraySet ContextButton Open\ in\ Dir :!pcmanfm "%:p:h<CR>"
  NeoraySet BoxDrawing TRUE
  NeoraySet KeyFullscreen <F11>
  NeoraySet KeyZoomIn     <C-=>
  NeoraySet KeyZoomOut    <C-->
  set guifont=:12
endif

]]

if vim.g.neovide then
  vim.o.guifont = "FiraCode Nerd Font:h14"
  vim.g.neovide_cursor_vfx_mode = "railgun"
  vim.g.neovide_floating_blur_amount_x = 200.0
  vim.g.neovide_floating_blur_amount_y = 200.0
  vim.g.neovide_scale_factor = 1.0
  vim.g.neovide_confirm_quit = false
  vim.g.neovide_fullscreen = false
  vim.cmd [[
    function! ChangeScaleFactor(delta)
        let g:neovide_scale_factor = g:neovide_scale_factor * a:delta
    endfunction
    nnoremap <expr><C-=> ChangeScaleFactor(1.25)
    nnoremap <expr><C--> ChangeScaleFactor(1/1.25)
  ]]
end

------------------------------------------------------------
-- Autosave ------------------------------------------------
------------------------------------------------------------

-- TODO dead code
-- -- Enable Autosave using CursorHold
-- vim.cmd [[
--     :set updatetime=300
--     :au CursorHold * :silent! wa
-- ]]
--
-- -- Write a function to toggle it
-- local auto_save = true
-- function ToggleAutoSave()
--   if auto_save then
--     vim.cmd [[ :au! ]]
--     auto_save = false
--     vim.cmd("echo 'Auto-save is OFF'")
--   else
--     vim.cmd [[ :au CursorHold * :silent! wa ]]
--     auto_save = true
--     vim.cmd("echo 'Auto-save is ON'")
--   end
-- end
--
--
-- vim.cmd [[
-- set conceallevel=0
-- ]]
--

------------------------------------------------------------
-- File Extensions -----------------------------------------
------------------------------------------------------------
vim.filetype.add({ extension = { txt = 'dokuwiki' } })
vim.filetype.add({ extension = { elv = 'elvish' } })
