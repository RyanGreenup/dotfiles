------------------------------------------------------------
-- Neovim Settings -----------------------------------------
------------------------------------------------------------
-- Reads all tuneable values from lua/config.lua.
-- This file only *applies* options and sets up autocommands/keymaps.

local cfg = require('config')
local cmd = vim.cmd
local g = vim.g
local opt = vim.opt

-----------------------------------------------------------
-- Leader
-----------------------------------------------------------
g.mapleader = ' '
vim.api.nvim_set_keymap('i', '<M-Space>', '<Esc><leader>', { noremap = true })

-----------------------------------------------------------
-- Editing
-----------------------------------------------------------
opt.mouse = cfg.editing.mouse
opt.clipboard = cfg.editing.clipboard
opt.swapfile = cfg.editing.swapfile
opt.autoread = cfg.editing.autoread
opt.ignorecase = cfg.editing.ignorecase
opt.smartcase = cfg.editing.smartcase
opt.completeopt = cfg.editing.completeopt

cmd [[imap jk <Esc>]]

-- Required for FUSE/NFS, see https://github.com/RyanGreenup/joplin_sqlite_fuse/commit/6d03b93
cmd [[set backupcopy=yes]]

-----------------------------------------------------------
-- UI
-----------------------------------------------------------
opt.number = cfg.ui.number
opt.relativenumber = cfg.ui.relativenumber
opt.showmatch = cfg.ui.showmatch
opt.colorcolumn = cfg.ui.colorcolumn
opt.splitright = cfg.ui.splitright
opt.splitbelow = cfg.ui.splitbelow
opt.linebreak = cfg.ui.linebreak
opt.termguicolors = cfg.ui.termguicolors

cmd [[ set modelineexpr ]] -- See vim modeline vulnerability 2019

-----------------------------------------------------------
-- Folding
-----------------------------------------------------------
opt.foldmethod = cfg.folding.method
opt.foldexpr = cfg.folding.expr
opt.foldlevel = cfg.folding.level
opt.foldlevelstart = cfg.folding.levelstart
opt.fillchars:append({ fold = " " })

-----------------------------------------------------------
-- Indentation
-----------------------------------------------------------
opt.expandtab = cfg.indentation.expandtab
opt.shiftwidth = cfg.indentation.width
opt.tabstop = cfg.indentation.width
opt.smartindent = cfg.indentation.smartindent

-- 2 spaces for selected filetypes
cmd [[autocmd FileType xml,html,xhtml,css,scss,javascript,lua,yaml setlocal shiftwidth=2 tabstop=2]]

-- don't auto commenting new lines
cmd [[au BufEnter * set fo-=c fo-=r fo-=o]]

-- remove line length marker for selected filetypes
cmd [[autocmd FileType text,markdown,html,xhtml,javascript setlocal cc=0]]

-----------------------------------------------------------
-- Performance
-----------------------------------------------------------
opt.hidden = cfg.performance.hidden
opt.history = cfg.performance.history
opt.lazyredraw = cfg.performance.lazyredraw
opt.synmaxcol = cfg.performance.synmaxcol

-----------------------------------------------------------
-- Behavior — autocommands
-----------------------------------------------------------
if cfg.behavior.trim_whitespace then
  cmd [[au BufWritePre * :%s/\s\+$//e]]
end

-- highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('YankHighlight', { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = cfg.ui.yank_highlight_timeout })
  end,
})

-----------------------------------------------------------
-- Colorscheme
-----------------------------------------------------------
require('config.themes').setup()

-----------------------------------------------------------
-- Terminal
-----------------------------------------------------------
cmd [[command Term :botright vsplit term://$SHELL]]
cmd [[
    autocmd TermOpen * setlocal listchars= nonumber norelativenumber nocursorline
    autocmd TermOpen * startinsert
    autocmd BufLeave term://* stopinsert
]]

-----------------------------------------------------------
-- Startup
-----------------------------------------------------------
local disabled_built_ins = {
  "gzip", "zip", "zipPlugin", "tar", "tarPlugin",
  "getscript", "getscriptPlugin", "vimball", "vimballPlugin",
  "2html_plugin", "logipat", "rrhelper", "spellfile_plugin", "matchit",
}
for _, plugin in pairs(disabled_built_ins) do
  g["loaded_" .. plugin] = 1
end

opt.shortmess:append "sI"

-----------------------------------------------------------
-- Misc Plugins
-----------------------------------------------------------
require('hlslens').setup()

-----------------------------------------------------------
-- Custom Commands
-----------------------------------------------------------
require('utils/insert_journal_table').setup()

-----------------------------------------------------------
-- Language Translation
-----------------------------------------------------------
function Line_to_esperanto()
  local cl = vim.api.nvim_get_current_line()
  local command = "argos-translate -f en -t eo '" .. cl .. "'"
  local out = io.popen(command):read()
  vim.api.nvim_set_current_line(out)
end

vim.api.nvim_set_keymap('n', '<M-r>', ':lua Line_to_esperanto() <CR>', { noremap = true })

-----------------------------------------------------------
-- Task Management
-----------------------------------------------------------
vim.cmd [[
:command InsertTaskTags :r ! cd ~/Agenda/Agenda_Maybe && cat (fd -t f) | rg "^:([\w\s/]+):" -r '$1' -o | sort -u<CR>
]]

-----------------------------------------------------------
-- GUI — Neoray
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

-----------------------------------------------------------
-- GUI — Neovide
-----------------------------------------------------------
if vim.g.neovide then
  vim.o.guifont = cfg.ui.gui_font
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

-- Enable Autosave (one toggle is enable)
require('utils/toggle_autosave').toggle()

-- Setup Outshine folding
require('utils.outshine_folding').setup()

------------------------------------------------------------
-- File Extensions -----------------------------------------
------------------------------------------------------------
vim.filetype.add({ extension = { txt = 'dokuwiki' } })
vim.filetype.add({ extension = { elv = 'elvish' } })
