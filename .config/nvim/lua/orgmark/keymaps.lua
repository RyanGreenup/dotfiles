--- Unified keybindings for orgmark.
--- Registers all buffer-local keymaps for markdown buffers in one place.
--- Call `M.setup(bufnr)` from the orgmark FileType autocmd.
local M = {}

--- Helper to detect if the current line is a list item.
---@param line string
---@return boolean
local function is_list_item(line)
  return line:match('^%s*[%-%*%+]%s') ~= nil
    or line:match('^%s*%d+[%.%)]%s') ~= nil
end

--- Helper to detect if the current line is a heading.
---@param line string
---@return boolean
local function is_heading(line)
  return line:match('^#+%s') ~= nil
end

--- Smart S-Up: if cursor is on a date, shift date up; otherwise cycle priority.
local function smart_shift_up()
  local line = vim.api.nvim_get_current_line()
  if line:match('%d%d%d%d%-%d%d%-%d%d') then
    require('orgmark.timestamps.shift').shift_up()
  else
    require('orgmark.todo.priority').cycle_priority()
  end
end

--- Smart S-Down: if cursor is on a date, shift date down; otherwise cycle priority.
local function smart_shift_down()
  local line = vim.api.nvim_get_current_line()
  if line:match('%d%d%d%d%-%d%d%-%d%d') then
    require('orgmark.timestamps.shift').shift_down()
  else
    require('orgmark.todo.priority').cycle_priority()
  end
end

--- Smart M-h: on a heading line, promote heading; on a list item, outdent.
local function smart_promote_or_outdent()
  local line = vim.api.nvim_get_current_line()
  if is_heading(line) then
    require('orgmark.headings').promote_heading()
  elseif is_list_item(line) then
    require('orgmark.lists.indent').outdent()
  end
end

--- Smart M-l: on a heading line, demote heading; on a list item, indent.
local function smart_demote_or_indent()
  local line = vim.api.nvim_get_current_line()
  if is_heading(line) then
    require('orgmark.headings').demote_heading()
  elseif is_list_item(line) then
    require('orgmark.lists.indent').indent()
  end
end

--- Set a buffer-local keymap with standard options.
---@param mode string|string[]  Mode(s) for the keymap
---@param lhs string            Left-hand side (key sequence)
---@param rhs function|string   Right-hand side (callback or command)
---@param desc string           Description for which-key
---@param bufnr number          Buffer number
local function bmap(mode, lhs, rhs, desc, bufnr)
  vim.keymap.set(mode, lhs, rhs, {
    buffer = bufnr,
    silent = true,
    desc = 'Orgmark: ' .. desc,
  })
end

--- Register all orgmark keybindings for a markdown buffer.
---@param bufnr number  Buffer number
function M.setup(bufnr)
  -- Folding ----------------------------------------------------------------
  local cycle = require('orgmark.folding.cycle')
  bmap('n', '<TAB>', cycle.cycle, 'local fold cycle', bufnr)
  bmap('n', '<S-TAB>', cycle.global_cycle, 'global fold cycle', bufnr)

  -- Heading management -----------------------------------------------------
  local headings = require('orgmark.headings')
  bmap('n', '<M-Left>', headings.promote_heading, 'promote heading', bufnr)
  bmap('n', '<M-Right>', headings.demote_heading, 'demote heading', bufnr)
  bmap('n', '<M-S-Left>', headings.promote_subtree, 'promote subtree', bufnr)
  bmap('n', '<M-S-Right>', headings.demote_subtree, 'demote subtree', bufnr)
  bmap({ 'n', 'i' }, '<C-CR>', headings.insert_child, 'insert child heading', bufnr)
  bmap({ 'n', 'i' }, '<M-CR>', headings.insert_sibling, 'insert sibling heading', bufnr)
  bmap('n', '<M-Up>', headings.move_up, 'move subtree up', bufnr)
  bmap('n', '<M-Down>', headings.move_down, 'move subtree down', bufnr)

  -- Navigation -------------------------------------------------------------
  bmap('n', '<C-c><C-n>', headings.next_heading, 'next heading', bufnr)
  bmap('n', '<C-c><C-p>', headings.prev_heading, 'previous heading', bufnr)
  bmap('n', '<C-c><C-f>', headings.next_sibling, 'next sibling heading', bufnr)
  bmap('n', '<C-c><C-b>', headings.prev_sibling, 'previous sibling heading', bufnr)
  bmap('n', '<C-c><C-u>', headings.parent, 'parent heading', bufnr)

  -- TODO / Checkbox / Priority ---------------------------------------------
  local todo = require('orgmark.todo')
  bmap('n', '<S-Right>', todo.cycle_forward, 'cycle TODO forward', bufnr)
  bmap('n', '<S-Left>', todo.cycle_backward, 'cycle TODO backward', bufnr)
  bmap('n', '<C-c><C-c>', require('orgmark.todo.checkbox').toggle, 'toggle checkbox', bufnr)
  bmap('n', '<S-Up>', smart_shift_up, 'shift date up / cycle priority', bufnr)
  bmap('n', '<S-Down>', smart_shift_down, 'shift date down / cycle priority', bufnr)

  -- Lists ------------------------------------------------------------------
  local lists = require('orgmark.lists')
  bmap('i', '<CR>', lists.smart_return, 'smart list continuation', bufnr)
  bmap('n', '<M-h>', smart_promote_or_outdent, 'promote heading / outdent list', bufnr)
  bmap('n', '<M-l>', smart_demote_or_indent, 'demote heading / indent list', bufnr)

  -- Timestamps -------------------------------------------------------------
  local timestamps = require('orgmark.timestamps')
  bmap('n', '<C-c>.', timestamps.insert_date, 'insert date', bufnr)
  bmap('n', '<C-c>!', timestamps.insert_timestamp, 'insert timestamp', bufnr)

  -- Narrow / Sparse --------------------------------------------------------
  local narrow = require('orgmark.narrow')
  bmap('n', '<C-x>ns', narrow.narrow_to_subtree, 'narrow to subtree', bufnr)
  bmap('n', '<C-x>nw', narrow.widen, 'widen', bufnr)

  local sparse = require('orgmark.sparse')
  bmap('n', '<C-c>/', sparse.search, 'sparse tree search', bufnr)
  bmap('n', '<C-c>/t', sparse.show_todos, 'show TODOs', bufnr)
  bmap('n', '<C-c>/d', sparse.show_done, 'show DONE', bufnr)

  -- Links ------------------------------------------------------------------
  local links = require('orgmark.links')
  bmap('n', '<C-c><C-l>', function() links.smart_link() end, 'insert/edit link', bufnr)
  bmap('v', '<C-c><C-l>', function() links.smart_link(true) end, 'link from selection', bufnr)
end

return M
