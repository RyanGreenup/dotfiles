--- Auto-renumbering for ordered markdown lists.
--- When an ordered list item is added, removed, or moved, this module
--- finds all consecutive items at the same indent level and renumbers
--- them sequentially starting from 1.
local M = {}

--- Determine the leading whitespace of a line.
---@param line string
---@return string indent  The leading whitespace
local function get_indent(line)
  return line:match('^(%s*)') or ''
end

--- Check if a line is an ordered list item and extract its parts.
---@param line string
---@return string|nil indent     Leading whitespace
---@return string|nil number_str The number as a string
---@return string|nil separator  The separator (`.` or `)`)
---@return string|nil rest       Everything after the number+separator+space
local function parse_ordered(line)
  local indent, num, sep, _, rest = line:match('^(%s*)(%d+)([%.%)])(%s+)(.*)')
  if indent then
    return indent, num, sep, rest
  end
  -- Handle case where there's nothing after the number+sep+space
  indent, num, sep = line:match('^(%s*)(%d+)([%.%)])%s*$')
  if indent then
    return indent, num, sep, ''
  end
  return nil, nil, nil, nil
end

--- Renumber consecutive ordered list items at the same indent level.
--- Scans outward from `start_line` to find the contiguous block of
--- ordered items sharing the same indentation, then numbers them 1, 2, 3, ...
---@param bufnr number   Buffer number (0 for current)
---@param start_line number  1-indexed line number of any item in the list
function M.renumber(bufnr, start_line)
  bufnr = bufnr or 0
  local line_count = vim.api.nvim_buf_line_count(bufnr)

  if start_line < 1 or start_line > line_count then
    return
  end

  local start_text = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, start_line, false)[1]
  if not start_text then
    return
  end

  local target_indent, _, target_sep, _ = parse_ordered(start_text)
  if not target_indent then
    return -- not an ordered list item
  end

  local target_indent_len = #target_indent

  -- Find the first item in this contiguous block by scanning upward.
  local first = start_line
  for i = start_line - 1, 1, -1 do
    local line = vim.api.nvim_buf_get_lines(bufnr, i - 1, i, false)[1]
    if not line then
      break
    end

    -- Allow blank lines within the block? Standard markdown doesn't,
    -- but loose lists do. We'll stop on blank lines for simplicity.
    if line:match('^%s*$') then
      break
    end

    local ind = get_indent(line)
    if #ind < target_indent_len then
      break -- parent or unrelated content
    end

    if #ind == target_indent_len then
      local it_ind, _, _, _ = parse_ordered(line)
      if it_ind then
        first = i
      else
        break -- different kind of item at same indent
      end
    end
    -- Lines at deeper indent belong to a sub-item; skip over them
  end

  -- Now scan forward from `first` and renumber.
  local counter = 1
  for i = first, line_count do
    local line = vim.api.nvim_buf_get_lines(bufnr, i - 1, i, false)[1]
    if not line then
      break
    end

    if line:match('^%s*$') then
      break -- end of list block
    end

    local ind = get_indent(line)
    if #ind < target_indent_len then
      break -- exited the block
    end

    if #ind == target_indent_len then
      local it_ind, _, it_sep, it_rest = parse_ordered(line)
      if it_ind then
        -- Use the separator from the original item for consistency
        local sep = it_sep or target_sep
        local new_line
        if it_rest == '' then
          new_line = it_ind .. counter .. sep .. ' '
        else
          new_line = it_ind .. counter .. sep .. ' ' .. it_rest
        end
        if new_line ~= line then
          vim.api.nvim_buf_set_lines(bufnr, i - 1, i, false, { new_line })
        end
        counter = counter + 1
      else
        break -- hit non-ordered content at same indent
      end
    end
    -- Lines at deeper indent are sub-items; skip but continue
  end
end

return M
