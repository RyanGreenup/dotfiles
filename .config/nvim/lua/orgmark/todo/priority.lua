--- Priority cycling for markdown headings.
--- Supports `[#A]`, `[#B]`, `[#C]` priority markers that appear after the
--- TODO keyword (or directly after the `#` markers when no keyword is present).
---
--- Example heading forms:
---   ## [#A] Important heading
---   ## TODO [#B] Somewhat important
---   ## DOING [#C] Low priority task
local M = {}

local todo = require('orgmark.todo')

--- Ordered list of priority levels to cycle through.
---@type string[]
M.priorities = { 'A', 'B', 'C' }

--- Cycle priority on the heading at the current line.
--- Sequence: (none) -> [#A] -> [#B] -> [#C] -> (none)
function M.cycle_priority()
  local bufnr = 0
  local line_nr = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_buf_get_lines(bufnr, line_nr - 1, line_nr, false)[1]
  if not line then
    return
  end

  -- Must be a heading line
  local marker, keyword, rest = todo.parse_heading(line)
  if not marker then
    return
  end

  -- Check if there's already a priority at the start of rest
  local existing_prio = rest:match('^%[#([A-C])%]')

  local new_prio = M.next_priority(existing_prio)

  -- Strip existing priority from rest if present
  local clean_rest = rest:gsub('^%[#[A-C]%]%s?', '')

  -- Build the new line
  local new_line
  if new_prio then
    local prio_str = '[#' .. new_prio .. ']'
    if keyword == '' then
      if clean_rest == '' then
        new_line = marker .. prio_str
      else
        new_line = marker .. prio_str .. ' ' .. clean_rest
      end
    else
      if clean_rest == '' then
        new_line = marker .. keyword .. ' ' .. prio_str
      else
        new_line = marker .. keyword .. ' ' .. prio_str .. ' ' .. clean_rest
      end
    end
  else
    -- No priority — remove it
    if keyword == '' then
      new_line = marker .. clean_rest
    else
      if clean_rest == '' then
        new_line = marker .. keyword
      else
        new_line = marker .. keyword .. ' ' .. clean_rest
      end
    end
  end

  vim.api.nvim_buf_set_lines(bufnr, line_nr - 1, line_nr, false, { new_line })
end

--- Get the next priority in the cycle.
---@param current string|nil  Current priority letter, or nil for none
---@return string|nil next  Next priority letter, or nil to remove
function M.next_priority(current)
  if current == nil then
    return M.priorities[1]
  end
  for i, prio in ipairs(M.priorities) do
    if prio == current then
      if i == #M.priorities then
        return nil -- wrap around: remove priority
      end
      return M.priorities[i + 1]
    end
  end
  -- Unknown priority — start from beginning
  return M.priorities[1]
end

return M
