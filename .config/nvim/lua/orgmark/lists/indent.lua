--- List item indentation (promotion/demotion) for markdown.
--- Adds or removes leading whitespace to change nesting level.
--- After indenting/outdenting, ordered lists are renumbered at both
--- the old and new indent levels.
local M = {}

local renumber = require('orgmark.lists.renumber')

--- Number of spaces per indent level.
---@type number
M.indent_width = 2

--- Check whether a line is a list item.
---@param line string
---@return boolean
local function is_list_item(line)
  return line:match('^%s*[%-%*%+]%s') ~= nil
    or line:match('^%s*%d+[%.%)]%s') ~= nil
end

--- Check whether a line is an ordered list item.
---@param line string
---@return boolean
local function is_ordered(line)
  return line:match('^%s*%d+[%.%)]%s') ~= nil
end

--- Indent (increase nesting) the list item on the current line.
--- Prepends `indent_width` spaces. If the item is an ordered list,
--- renumbers at the new indent level.
--- Works in both normal and insert mode.
function M.indent()
  local bufnr = 0
  local line_nr = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_buf_get_lines(bufnr, line_nr - 1, line_nr, false)[1]
  if not line or not is_list_item(line) then
    return
  end

  local spaces = string.rep(' ', M.indent_width)
  local new_line = spaces .. line
  vim.api.nvim_buf_set_lines(bufnr, line_nr - 1, line_nr, false, { new_line })

  -- Adjust cursor position to stay on the same text
  local cursor = vim.api.nvim_win_get_cursor(0)
  vim.api.nvim_win_set_cursor(0, { cursor[1], cursor[2] + M.indent_width })

  -- Renumber ordered lists at the new indent level
  if is_ordered(new_line) then
    renumber.renumber(bufnr, line_nr)
  end
end

--- Outdent (decrease nesting) the list item on the current line.
--- Removes up to `indent_width` leading spaces (never goes below 0).
--- If the item is an ordered list, renumbers at the new indent level.
--- Works in both normal and insert mode.
function M.outdent()
  local bufnr = 0
  local line_nr = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_buf_get_lines(bufnr, line_nr - 1, line_nr, false)[1]
  if not line or not is_list_item(line) then
    return
  end

  local leading = line:match('^(%s*)')
  local current_indent = #leading
  local remove = math.min(current_indent, M.indent_width)

  if remove == 0 then
    return -- already at column 0
  end

  local new_line = line:sub(remove + 1)
  vim.api.nvim_buf_set_lines(bufnr, line_nr - 1, line_nr, false, { new_line })

  -- Adjust cursor position
  local cursor = vim.api.nvim_win_get_cursor(0)
  local new_col = math.max(0, cursor[2] - remove)
  vim.api.nvim_win_set_cursor(0, { cursor[1], new_col })

  -- Renumber ordered lists at the new indent level
  if is_ordered(new_line) then
    renumber.renumber(bufnr, line_nr)
  end
end

return M
