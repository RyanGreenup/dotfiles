--- TODO state cycling for markdown headings.
--- Supports cycling through configurable keyword states (e.g. TODO -> DOING -> DONE)
--- on ATX headings.  The keyword sits between the `#` markers and the heading text:
---   ## TODO Fix the parser
---   ## DOING Fix the parser
---   ## DONE Fix the parser
local M = {}

--- Ordered list of TODO states to cycle through.
--- An empty string represents "no keyword" and is implicit at each end.
---@type string[]
M.states = { 'TODO', 'DOING', 'DONE' }

--- Detect the current TODO state on a heading line.
---@param line string  The full line text
---@return string|nil marker   The `#+ ` prefix (nil if not a heading)
---@return string|nil keyword  The matched keyword, or "" if none
---@return string|nil rest     The remaining heading text after the keyword
function M.parse_heading(line)
  local marker, rest = line:match('^(#+%s+)(.*)')
  if not marker then
    return nil, nil, nil
  end

  for _, state in ipairs(M.states) do
    -- Check if the rest starts with the keyword followed by a space (or end of string)
    local after = rest:match('^' .. state .. '%s+(.*)')
    if after then
      return marker, state, after
    end
    -- Keyword at end of line with no trailing text
    if rest == state then
      return marker, state, ''
    end
  end

  -- No keyword found — heading has no TODO state
  return marker, '', rest
end

--- Get the next state in the forward direction.
---@param current string  Current keyword ("" for none)
---@return string next  The next keyword ("" to remove)
function M.next_state(current)
  if current == '' then
    return M.states[1]
  end
  for i, state in ipairs(M.states) do
    if state == current then
      if i == #M.states then
        return '' -- wrap around: remove keyword
      end
      return M.states[i + 1]
    end
  end
  -- Unknown state — start from the beginning
  return M.states[1]
end

--- Get the previous state in the backward direction.
---@param current string  Current keyword ("" for none)
---@return string prev  The previous keyword ("" to remove)
function M.prev_state(current)
  if current == '' then
    return M.states[#M.states]
  end
  for i, state in ipairs(M.states) do
    if state == current then
      if i == 1 then
        return '' -- wrap around: remove keyword
      end
      return M.states[i - 1]
    end
  end
  -- Unknown state — start from the end
  return M.states[#M.states]
end

--- Build the new heading line after applying a state transition.
---@param marker string   The `#+ ` prefix
---@param keyword string  The new keyword ("" to remove)
---@param rest string     The heading text after the keyword
---@return string line  The reconstructed heading line
local function build_heading(marker, keyword, rest)
  if keyword == '' then
    return marker .. rest
  end
  if rest == '' then
    return marker .. keyword
  end
  return marker .. keyword .. ' ' .. rest
end

--- Cycle TODO state forward on the current line.
--- Sequence: (none) -> TODO -> DOING -> DONE -> (none)
function M.cycle_forward()
  local line_nr = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_buf_get_lines(0, line_nr - 1, line_nr, false)[1]
  if not line then
    return
  end

  local marker, keyword, rest = M.parse_heading(line)
  if not marker then
    return -- not a heading line
  end

  local new_kw = M.next_state(keyword)
  local new_line = build_heading(marker, new_kw, rest)
  vim.api.nvim_buf_set_lines(0, line_nr - 1, line_nr, false, { new_line })
end

--- Cycle TODO state backward on the current line.
--- Sequence: (none) -> DONE -> DOING -> TODO -> (none)
function M.cycle_backward()
  local line_nr = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_buf_get_lines(0, line_nr - 1, line_nr, false)[1]
  if not line then
    return
  end

  local marker, keyword, rest = M.parse_heading(line)
  if not marker then
    return -- not a heading line
  end

  local new_kw = M.prev_state(keyword)
  local new_line = build_heading(marker, new_kw, rest)
  vim.api.nvim_buf_set_lines(0, line_nr - 1, line_nr, false, { new_line })
end

return M
