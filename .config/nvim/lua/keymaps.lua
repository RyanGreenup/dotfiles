-----------------------------------------------------------
-- Keymaps configuration file: keymaps of neovim
-- and plugins.
-----------------------------------------------------------

local map = vim.api.nvim_set_keymap
local default_opts = { noremap = true, silent = true }

--- Create a Keymapping with a vim command
local function mp(mode, key, command)
  vim.api.nvim_set_keymap(mode, key, command, default_opts)
end

local function nmap(keymap_table)
  for _, table in pairs(keymap_table) do
    local key = table[1]
    local func = table[2]
    local desc = table.desc
    local opts = { noremap = default_opts.nnoremap, silent = default_opts.nnoremap, callback = func, desc = desc }
    vim.api.nvim_set_keymap('n', key, '', opts)
  end
end


-----------------------------------------------------------
-- Neovim shortcuts:
-----------------------------------------------------------

-- clear search highlighting
mp('n', '<C-/>', ':nohl<CR>')


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
map('n', '<PageUp>', '<cmd>tabnext<CR>', default_opts)
map('n', '<PageDown>', '<cmd>tabprev<CR>', default_opts)
map('n', '<Insert>', '<cmd>tabnew<CR>', default_opts)

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

-- Vista tag-viewer
map('n', '<C-m>', ':Outline<CR>', default_opts) -- open/close


------------------------------------------------------------
-- Markdown stuff
------------------------------------------------------------
map('n', '<C-PageDown>', '<cmd>lua Change_dayplanner_line(-30)<CR>', default_opts)
map('n', '<C-PageUp>', '<cmd>lua Change_dayplanner_line(30)<CR>', default_opts)
map('i', '<M-l>', '<cmd>lua My_snippy_state.toggles.latex()<CR>', default_opts)


-- vim.cmd [[ autocmd BufEnter *.md :map <f2> :! pandoc -s --katex "%" -o "%".html && chromium "%".html & disown <Enter> <Enter> ]]
-- vim.cmd [[ autocmd BufEnter *.md :setlocal filetype=markdown ]]
-- vim.cmd [[ autocmd BufEnter *.md :nmap <leader>v :MarkdownPreview<CR> ]]
--
-- vim.cmd [[
--     nmap <Leader>meelo :!pandoc -s --self-contained "%" --listings --toc  -H ~/Templates/LaTeX/ScreenStyle.sty --pdf-engine-opt=-shell-escape --citeproc --bibliography $HOME/Sync/Documents/ref.bib -o /tmp/note.pdf ; xdg-open /tmp/note.pdf & disown
--
--
--     nmap <Leader>meeho :!pandoc -s --self-contained "%"  --toc -H ~/Templates/CSS/gitOrgWrapped.css --citeproc --bibliography $HOME/Sync/Documents/ref.bib  --csl ~/Templates/CSL/nature.csl -o /tmp/note.html ; cat ~/Templates/mathjax >> /tmp/note.html; xdg-open /tmp/note.html
--
--     nmap <Leader>meehom :!pandoc -s --self-contained "%" --mathml --toc -H ~/Templates/CSS/gitOrgWrapped.css --csl ~/Templates/CSL/nature.csl --citeproc --bibliography $HOME/Sync/Documents/ref.bib  -o /tmp/note.html ;  xdg-open /tmp/note.html
--
-- ]]
--

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
vim.g.tabby_trigger_mode = 'auto'
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


local function map_current_buf(mode, desc, key, func)
  vim.api.nvim_buf_set_keymap(0, mode, key, '',
    {
      callback = func,
      noremap = true,
      silent = true,
      desc = desc
    })
end


local function normal_map_current_buf(desc, key, func)
  map_current_buf('n', desc, key, func)
end

--------------------------------------------------------------------------------
-- Autocommand Keymaps ---------------------------------------------------------
--------------------------------------------------------------------------------
vim.api.nvim_create_autocmd({ 'FileType' }, {
  pattern = { 'markdown', 'rmd' },
  callback = function()
    -- Slime
    normal_map_current_buf(
      "Evaluate Markdown Cell with Slime and tmux",
      '<M-S-CR>', require("utils/slime_utils").send_slime_markdown_cell
    )
    normal_map_current_buf(
      "Send all Markdown Cells",
      '<M-C-r>', require("utils/slime_utils").send_all_markdown_cells
    )
    normal_map_current_buf(
      "Evaluate Next Code Cell with Slime and tmux",
      '<M-C-n>', require("utils/slime_utils").send_next_markdown_cell
    )
    normal_map_current_buf(
      "Evaluate Previous Code Cell with Slime and tmux",
      '<M-C-p>', require("utils/slime_utils").send_prev_markdown_cell
    )
    normal_map_current_buf(
      "Use Treesitter to Insert a Markdown Heading of the right level",
      '<C-CR>', require('utils/markdown_headings').insert_subheading_below
    )
    normal_map_current_buf(
      "Use Treesitter to Insert a Markdown Heading of the right level",
      '<A-CR>',
      require('utils/markdown_headings').insert_heading_below)

    -- TODO this no longer works :(
    normal_map_current_buf(
      "Use Treesitter to demote a Markdown Heading",
      '<M-Left>',
      require('utils/markdown_headings').demote_heading)

    normal_map_current_buf(
      "Use Treesitter to promote a Markdown Heading",
      '<M-Right>',
      require('utils/markdown_headings').promote_heading)

    normal_map_current_buf(
      "Use Treesitter to promote a Markdown Heading",
      '<M-h>',
      require('utils/markdown_headings').promote_all_headings_below)

    normal_map_current_buf(
      "Use Treesitter to promote a Markdown Heading",
      '<M-l>',
      require('utils/markdown_headings').demote_all_headings_below)
  end,

})

vim.api.nvim_create_autocmd({ 'FileType' }, {
  pattern = { 'dokuwiki' },
  callback = function()
    normal_map_current_buf(
      "Use Treesitter to Insert a Dokuwiki Heading of the right level",
      '<C-CR>', require('dokuwiki/headings').insert_subheading_below
    )
    normal_map_current_buf(
      "Insert a Dokuwiki Heading of the right level",
      '<A-CR>',
      require('dokuwiki/headings').insert_heading_below)

    -- TODO this no longer works :(
    normal_map_current_buf(
      "demote a Dokuwiki Heading",
      '<M-Left>',
      require('dokuwiki/headings').demote_heading)

    normal_map_current_buf(
      "Promote a Dokuwiki Heading",
      '<M-Right>',
      require('dokuwiki/headings').promote_heading)

    normal_map_current_buf(
      "Promote a Dokuwiki Heading",
      '<M-h>',
      require('dokuwiki/headings').promote_all_headings_below)

    normal_map_current_buf(
      "Promote a Dokuwiki Heading",
      '<M-l>',
      require('dokuwiki/headings').demote_all_headings_below)

    normal_map_current_buf(
      "Follow Link",
      '<CR>',
      function()
        require('dokuwiki/config').edit_link_under_cursor()
      end)
  end,
})





--------------------------------------------------------------------------------
-- TODO Consider making this a module and sourcing it for plugins ? ------------
--------------------------------------------------------------------------------
-- That way keybindings can be set when the plugin is loaded
-- i.e. a link from plugin to keybinding (and naturally a link back to plugins/)
-- but all keybindings remain centralised

-- NOTE lazy supports mapping keybindings with a table of {key, func, desc}
-- this is consistent with which key, so here we make our own function to deal
-- with those tables and call them in there, to avoid lock in and keep keymaps
-- in one file

local M = {} -- define a table to hold our module

-- Define the function we want to export

function M.neotree()
  nmap({ { '<C-n>', function() vim.cmd([[Neotree toggle]]) end, desc = "Toggle Neotree" } })
end

function M.dap_keymaps()
  nmap({
    { "<F4>",  require('dapui').toggle,          desc = "Toggle DapUI" },
    { "<F9>",  require('dap').toggle_breakpoint, desc = "Toggle Dap Breakpoint" },
    { "<F5>",  require('dap').continue,          desc = "Dap Continue" },
    { "<F10>", require('dap').step_over,         desc = "Step over" },
    { "<F11>", require('dap').step_into,         desc = "Step into" },
    { "<F23>", require('dap').step_out,          desc = "Step Out" },
  })
end

function M.fold_cycle()
  nmap(
    { { '<tab>', require('fold-cycle').open,      desc = 'Fold-cycle: open folds' },
      { '<s-tab>', require('fold-cycle').close,     desc = 'Fold-cycle: close folds' },
      { 'zC',      require('fold-cycle').close_all, desc = 'Fold-cycle: close all folds' } })
end

function M.outline_plugin()
  nmap(
    { { '<-m>', function() vim.cmd [[Outline]] end, desc = "Outline Toggle" },
    })
end

function M.yazi()
  nmap({
    {
      "<leader>-",
      function()
        require("yazi").yazi()
      end,
      desc = "Open the file manager",
    },
    {
      -- Open in the current working directory
      "<leader>cw",
      function()
        require("yazi").yazi(nil, vim.fn.getcwd())
      end,
      desc = "Open the file manager in nvim's working directory",
    },
  })
end

local function terminal_escape()
  vim.api.nvim_feedkeys(
  -- "<Esc>" seems to work too
    vim.api.nvim_replace_termcodes("<C-n>", true, false, true),
    'n',
    false)
end

function M.fterm()
  local repl_key = '<C-`>'
  map('n', repl_key, '', {
    noremap = true,
    callback = function()
      local win_id = vim.api.nvim_get_current_win()
      require("config.fterm").gitui:toggle()
      -- move focus back to current window
      -- vim.api.nvim_set_current_win(win_id)
    end
  })
  map('t', repl_key, '', {
    noremap = true,
    callback = function()
      terminal_escape()
      require("config.fterm").gitui:toggle()
    end
  })
  -- map('n', '<A-i>', '', { noremap = true, callback = function() require("config.fterm").tmux:toggle() end })
  -- map('t', '<A-i>', '', {
  --   noremap = true,
  --   callback = function()
  --     terminal_escape()
  --     require("Fterm").toggle()
  --   end
  -- })
end

map('n', '<A-i>', '<CMD>lua require("FTerm").toggle()<CR>', { noremap = true })
map('t', '<A-i>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>', { noremap = true })

-- Return the module table so that it can be required by other scripts
return M
