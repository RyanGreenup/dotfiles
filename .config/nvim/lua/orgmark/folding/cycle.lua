--- Fold cycling for orgmark.
--- Provides org-mode-style TAB (local) and S-TAB (global) fold cycling.
local ts = require('orgmark.treesitter')

local M = {}

--- Echo a short status message using the MoreMsg highlight group.
---@param msg string  The message to display
local function echo_info(msg)
  vim.api.nvim_echo({ { msg, 'MoreMsg' } }, false, {})
end

--- Local fold cycle on the current line.
--- Three-state cycle mimicking org-mode behavior:
---   Folded -> Children visible -> Fully expanded -> Folded
function M.cycle()
  local line = vim.fn.line('.')

  -- If folding is disabled, re-enable and recompute folds
  if not vim.wo.foldenable then
    vim.wo.foldenable = true
    vim.cmd('silent! normal! zx')
  end

  -- If the current line has no fold, inform the user
  local level = vim.fn.foldlevel(line)
  if level == 0 then
    return echo_info('No fold')
  end

  -- State 1: fold is closed -> open one level
  if vim.fn.foldclosed(line) ~= -1 then
    vim.cmd('silent! normal! zo')
    return echo_info('Children')
  end

  -- We need the section node to inspect children
  local bufnr = vim.api.nvim_get_current_buf()
  local section = ts.get_section_at_line(bufnr, line)
  if not section then
    return
  end

  --- Check whether a section is expandable (has children or body content).
  ---@param sec TSNode
  ---@return boolean
  local function is_expandable(sec)
    return ts.has_child_sections(sec) or not ts.is_one_line(sec)
  end

  if not is_expandable(section) then
    return
  end

  local children = ts.get_child_sections(section)
  local should_close = #children == 0

  if not should_close then
    local has_nested_children = false
    for _, child in ipairs(children) do
      local child_expandable = is_expandable(child)
      if not has_nested_children and child_expandable then
        has_nested_children = true
      end
      local child_line = ts.get_heading_line(child)
      if child_line and child_expandable and vim.fn.foldclosed(child_line) == -1 then
        -- Found an open child that can be closed -> cycle to close
        vim.cmd(string.format('silent! keepjumps normal! %dggzc', child_line))
        should_close = true
      end
    end
    -- Restore cursor to original line
    vim.cmd(string.format('silent! keepjumps normal! %dgg', line))
    -- If no nested expandable children exist, close the parent
    if not should_close and not has_nested_children then
      should_close = true
    end
  end

  -- State 3: fully open -> close
  if should_close then
    vim.cmd('silent! normal! zc')
    return echo_info('Folded')
  end

  -- State 2: open with closed children -> recursively open all
  vim.cmd('silent! normal! zczO')
  return echo_info('Subtree')
end

--- Global fold cycle for the whole buffer.
--- Cycles through three states tracked in `vim.w.orgmark_global_state`:
---   Overview -> Contents -> Show All -> Overview
function M.global_cycle()
  if not vim.wo.foldenable or vim.w.orgmark_global_state == 'Show All' then
    vim.w.orgmark_global_state = 'Overview'
    vim.cmd('silent! normal! zMzX')
    return echo_info('OVERVIEW')
  end

  if vim.w.orgmark_global_state == 'Contents' then
    vim.w.orgmark_global_state = 'Show All'
    vim.cmd('silent! normal! zR')
    return echo_info('SHOW ALL')
  end

  vim.w.orgmark_global_state = 'Contents'
  vim.wo.foldlevel = 1
  vim.cmd('silent! normal! zx')
  return echo_info('CONTENTS')
end

return M
