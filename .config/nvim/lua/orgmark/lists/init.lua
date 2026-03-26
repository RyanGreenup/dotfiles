--- Smart list continuation for markdown.
--- Provides `smart_return()` which, when bound to RET in insert mode,
--- automatically continues list items, increments ordered list numbers,
--- adds empty checkboxes, and cleanly exits lists when the item is empty.
local M = {}

local renumber = require('orgmark.lists.renumber')

--- Patterns for detecting list item types.
--- Each returns captures that let us reconstruct the prefix.
---@type table<string, string>
M.patterns = {
  --- Checkbox on unordered list: `  - [x] `, `* [ ] `, etc.
  checkbox_unordered = '^(%s*[%-%*%+]%s+)%[([%sx%-])%](%s+)',
  --- Checkbox on ordered list: `  1. [x] `, `2) [ ] `, etc.
  checkbox_ordered = '^(%s*%d+[%.%)])(%s+)%[([%sx%-])%](%s+)',
  --- Ordered list item: `  1. `, `2) `, etc.
  ordered = '^(%s*)(%d+)([%.%)])(%s+)',
  --- Unordered list item: `  - `, `* `, `+ `, etc.
  unordered = '^(%s*)([%-%*%+])(%s+)',
}

--- Detect the list type and extract prefix components from a line.
---@param line string  The line text to analyze
---@return table|nil info  Table with type, indent, marker, and content fields; nil if not a list item
function M.detect(line)
  -- Try checkbox on unordered list first (most specific)
  local prefix, cb_state, post_cb_space = line:match(M.patterns.checkbox_unordered)
  if prefix then
    local content = line:sub(#prefix + 3 + #post_cb_space + 1) -- +3 for [x]
    return {
      type = 'checkbox_unordered',
      full_prefix = prefix .. '[' .. cb_state .. ']' .. post_cb_space,
      indent = line:match('^(%s*)'),
      marker = prefix:match('[%-%*%+]'),
      checkbox = cb_state,
      content = content,
    }
  end

  -- Checkbox at end of line with no trailing space: `- [ ]` or `- [x]`
  local cb_prefix2, cb_state2 = line:match('^(%s*[%-%*%+]%s+)%[([%sx%-])%]$')
  if cb_prefix2 then
    return {
      type = 'checkbox_unordered',
      full_prefix = cb_prefix2 .. '[' .. cb_state2 .. ']',
      indent = line:match('^(%s*)'),
      marker = cb_prefix2:match('[%-%*%+]'),
      checkbox = cb_state2,
      content = '',
    }
  end

  -- Try checkbox on ordered list
  local ord_prefix, ord_space1, ord_cb, ord_space2 = line:match(M.patterns.checkbox_ordered)
  if ord_prefix then
    local full = ord_prefix .. ord_space1 .. '[' .. ord_cb .. ']' .. ord_space2
    local content = line:sub(#full + 1)
    local num = ord_prefix:match('(%d+)')
    local sep = ord_prefix:match('[%.%)]')
    return {
      type = 'checkbox_ordered',
      full_prefix = full,
      indent = line:match('^(%s*)'),
      number = tonumber(num),
      separator = sep,
      checkbox = ord_cb,
      content = content,
    }
  end

  -- Checkbox on ordered list at end of line: `1. [ ]`
  local ord_prefix2, ord_space2a, ord_cb2 = line:match('^(%s*%d+[%.%)])(%s+)%[([%sx%-])%]$')
  if ord_prefix2 then
    local num = ord_prefix2:match('(%d+)')
    local sep = ord_prefix2:match('[%.%)]')
    return {
      type = 'checkbox_ordered',
      full_prefix = ord_prefix2 .. ord_space2a .. '[' .. ord_cb2 .. ']',
      indent = line:match('^(%s*)'),
      number = tonumber(num),
      separator = sep,
      checkbox = ord_cb2,
      content = '',
    }
  end

  -- Try ordered list
  local indent, num, sep, space = line:match(M.patterns.ordered)
  if indent then
    local full = indent .. num .. sep .. space
    local content = line:sub(#full + 1)
    return {
      type = 'ordered',
      full_prefix = full,
      indent = indent,
      number = tonumber(num),
      separator = sep,
      content = content,
    }
  end

  -- Try unordered list
  local u_indent, u_marker, u_space = line:match(M.patterns.unordered)
  if u_indent then
    local full = u_indent .. u_marker .. u_space
    local content = line:sub(#full + 1)
    return {
      type = 'unordered',
      full_prefix = full,
      indent = u_indent,
      marker = u_marker,
      content = content,
    }
  end

  return nil
end

--- Build the continuation prefix for a new list item.
--- For ordered lists, increments the number. For checkboxes, starts unchecked.
---@param info table  The parsed list item info from `detect()`
---@return string prefix  The prefix for the new list item
local function continuation_prefix(info)
  if info.type == 'checkbox_unordered' then
    return info.indent .. info.marker .. ' [ ] '
  elseif info.type == 'checkbox_ordered' then
    local next_num = info.number + 1
    return info.indent .. next_num .. info.separator .. ' [ ] '
  elseif info.type == 'ordered' then
    local next_num = info.number + 1
    return info.indent .. next_num .. info.separator .. ' '
  elseif info.type == 'unordered' then
    return info.indent .. info.marker .. ' '
  end
  return ''
end

--- Smart return handler for insert mode.
--- Behavior depends on the current line:
---
--- 1. **List item with content**: Insert a new line with the same list prefix.
---    Ordered lists auto-increment. Checkboxes start unchecked.
---
--- 2. **Empty list item** (just prefix, no content): Delete the prefix and
---    leave a blank line.  This exits the list naturally.
---
--- 3. **Non-list line**: Perform a normal `<CR>`.
---
--- This function is designed to be called from an insert-mode mapping.
--- It manipulates the buffer directly and positions the cursor correctly.
function M.smart_return()
  local bufnr = 0
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line_nr = cursor[1]
  local col = cursor[2]
  local line = vim.api.nvim_buf_get_lines(bufnr, line_nr - 1, line_nr, false)[1]

  if not line then
    -- Empty buffer / unexpected state — just do a normal return
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', false)
    return
  end

  local info = M.detect(line)

  if not info then
    -- Not a list item — normal return
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', false)
    return
  end

  -- Check if the list item is empty (just the prefix, no content)
  if info.content:match('^%s*$') then
    -- Replace current line with an empty line (exit list)
    vim.api.nvim_buf_set_lines(bufnr, line_nr - 1, line_nr, false, { '' })
    vim.api.nvim_win_set_cursor(0, { line_nr, 0 })
    return
  end

  -- The cursor may be in the middle of the line content. We need to split
  -- the text at the cursor position: everything before the cursor stays on
  -- the current line, everything after moves to the new line.
  local before_cursor = line:sub(1, col)
  local after_cursor = line:sub(col + 1)

  local new_prefix = continuation_prefix(info)

  -- Update current line to only have text up to cursor
  vim.api.nvim_buf_set_lines(bufnr, line_nr - 1, line_nr, false, { before_cursor })

  -- Insert new line below with the continuation prefix + remaining text
  local new_line = new_prefix .. after_cursor
  vim.api.nvim_buf_set_lines(bufnr, line_nr, line_nr, false, { new_line })

  -- Position cursor at end of new prefix (ready to type)
  vim.api.nvim_win_set_cursor(0, { line_nr + 1, #new_prefix })

  -- Renumber if this is an ordered list
  if info.type == 'ordered' or info.type == 'checkbox_ordered' then
    renumber.renumber(bufnr, line_nr + 1)
  end
end

return M
