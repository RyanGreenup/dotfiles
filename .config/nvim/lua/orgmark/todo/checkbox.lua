--- Checkbox toggling and statistics cookies for markdown lists.
--- Supports `- [ ]`, `- [x]`, and `- [-]` checkboxes with any list marker
--- (`-`, `*`, `+`) and any level of indentation.
---
--- Statistics cookies (`[2/5]` or `[40%]`) in parent items are updated
--- automatically when a child checkbox is toggled.
local M = {}

--- Pattern matching a checkbox on a list line.
--- Captures:
---   1. prefix — everything before the bracket (indent + marker + space)
---   2. state  — the character inside brackets: space, x, or -
---@type string
local CHECKBOX_PAT = '^(%s*[%-%*%+]%s+)%[([%sx%-])%]'

--- Toggle the checkbox on the current line.
--- `[ ]` -> `[x]`,  `[x]` -> `[ ]`,  `[-]` -> `[ ]`
--- After toggling, updates any statistics cookie on the parent item.
function M.toggle()
  local bufnr = 0
  local line_nr = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_buf_get_lines(bufnr, line_nr - 1, line_nr, false)[1]
  if not line then
    return
  end

  local prefix, state = line:match(CHECKBOX_PAT)
  if not prefix then
    return -- not a checkbox line
  end

  local new_state
  if state == ' ' then
    new_state = 'x'
  else
    -- [x] or [-] both go back to [ ]
    new_state = ' '
  end

  local new_line = prefix .. '[' .. new_state .. ']' .. line:sub(#prefix + 4)
  vim.api.nvim_buf_set_lines(bufnr, line_nr - 1, line_nr, false, { new_line })

  -- Update parent statistics cookie
  M.update_statistics(bufnr, line_nr)
end

--- Determine the indentation level (number of leading spaces) of a line.
---@param line string
---@return number indent  Number of leading whitespace characters
local function indent_of(line)
  local ws = line:match('^(%s*)')
  return ws and #ws or 0
end

--- Check whether a line is a list item (ordered or unordered).
---@param line string
---@return boolean
local function is_list_item(line)
  return line:match('^%s*[%-%*%+]%s') ~= nil
    or line:match('^%s*%d+[%.%)]%s') ~= nil
end

--- Check whether a line contains a checkbox.
---@param line string
---@return boolean is_checkbox
---@return boolean is_checked
local function checkbox_state(line)
  local _, state = line:match(CHECKBOX_PAT)
  if not state then
    return false, false
  end
  return true, (state == 'x')
end

--- Find the parent list item for the item at `line_nr`.
--- The parent is the closest list item above with strictly less indentation.
---@param bufnr number  Buffer number
---@param line_nr number  1-indexed line number of the child item
---@return number|nil parent_line  1-indexed line of the parent, or nil
local function find_parent_item(bufnr, line_nr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, line_nr, false)
  if #lines == 0 then
    return nil
  end

  local child_indent = indent_of(lines[line_nr])

  -- Walk upward looking for a list item with less indentation
  for i = line_nr - 1, 1, -1 do
    local l = lines[i]
    if is_list_item(l) then
      local ind = indent_of(l)
      if ind < child_indent then
        return i
      end
    end
    -- If we hit a non-blank, non-list line at same or lower indent, stop
    if l:match('%S') and not is_list_item(l) then
      local ind = indent_of(l)
      if ind <= child_indent then
        return nil
      end
    end
  end

  return nil
end

--- Collect direct child checkboxes of the item at `parent_line`.
--- Direct children are list items at exactly `parent_indent + 2` (or the
--- next deeper indent level) that appear consecutively below the parent,
--- before a line at equal or lesser indentation.
---@param bufnr number
---@param parent_line number  1-indexed line number of the parent
---@return number checked   Count of checked children
---@return number total     Count of total checkbox children
local function count_child_checkboxes(bufnr, parent_line)
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  local parent_text = vim.api.nvim_buf_get_lines(bufnr, parent_line - 1, parent_line, false)[1]
  if not parent_text then
    return 0, 0
  end

  local parent_indent = indent_of(parent_text)
  local child_indent = nil -- determined by first child encountered

  local checked = 0
  local total = 0

  for i = parent_line + 1, line_count do
    local line = vim.api.nvim_buf_get_lines(bufnr, i - 1, i, false)[1]
    if not line then
      break
    end

    local ind = indent_of(line)

    -- Skip blank lines
    if line:match('^%s*$') then
      goto continue
    end

    -- Stop if we hit something at parent indent or less
    if ind <= parent_indent then
      break
    end

    -- Determine child indent from first child list item
    if is_list_item(line) and child_indent == nil then
      child_indent = ind
    end

    -- Only count items at the direct child indent level
    if child_indent and ind == child_indent and is_list_item(line) then
      local is_cb, is_chk = checkbox_state(line)
      if is_cb then
        total = total + 1
        if is_chk then
          checked = checked + 1
        end
      end
    end

    ::continue::
  end

  return checked, total
end

--- Update statistics cookies on the parent of the item at `line_nr`.
--- Recognizes two cookie formats:
---   - Fraction: `[2/5]`
---   - Percent:  `[40%]`
--- Only updates cookies that already exist — never auto-inserts them.
---@param bufnr number  Buffer number
---@param line_nr number  1-indexed line number of the toggled checkbox
function M.update_statistics(bufnr, line_nr)
  local parent_line = find_parent_item(bufnr, line_nr)
  if not parent_line then
    -- Also check if a heading line right above contains a cookie.
    -- Walk up to find a heading.
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, line_nr, false)
    for i = line_nr - 1, 1, -1 do
      local l = lines[i]
      if l:match('^#+%s') then
        parent_line = i
        break
      end
      -- If we hit non-blank, non-list content, stop
      if l:match('%S') and not is_list_item(l) and not l:match('^%s*$') then
        break
      end
    end
    if not parent_line then
      return
    end
  end

  local parent_text = vim.api.nvim_buf_get_lines(bufnr, parent_line - 1, parent_line, false)[1]
  if not parent_text then
    return
  end

  -- Check if the parent has a fraction cookie [N/M]
  local has_fraction = parent_text:match('%[%d+/%d+%]') ~= nil
  -- Check if the parent has a percent cookie [N%]
  local has_percent = parent_text:match('%[%d+%%%]') ~= nil

  if not has_fraction and not has_percent then
    return -- no cookies to update
  end

  local checked, total = count_child_checkboxes(bufnr, parent_line)

  if total == 0 then
    return -- no children to count
  end

  local new_text = parent_text

  if has_fraction then
    new_text = new_text:gsub('%[%d+/%d+%]', '[' .. checked .. '/' .. total .. ']', 1)
  end

  if has_percent then
    local pct = math.floor((checked / total) * 100)
    new_text = new_text:gsub('%[%d+%%%]', '[' .. pct .. '%%]', 1)
  end

  if new_text ~= parent_text then
    vim.api.nvim_buf_set_lines(bufnr, parent_line - 1, parent_line, false, { new_text })
  end
end

return M
