--- Move subtrees up or down by swapping with sibling sections.
local M = {}

local ts = require('orgmark.treesitter')

--- Recompute folds after a heading modification.
local function update_folds()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('zx', true, false, true), 'n', false)
end

--- Find sibling sections of the given section node.
--- Returns the list of sibling section nodes and the index of the current section.
---@param section TSNode  The current section node
---@return TSNode[] siblings  All sibling sections (in document order)
---@return number|nil index  1-based index of `section` in the siblings list
local function find_siblings(section)
  local parent = section:parent()
  if not parent then
    return {}, nil
  end

  local siblings = {}
  local current_idx = nil

  for child in parent:iter_children() do
    if child:named() and child:type() == 'section' then
      siblings[#siblings + 1] = child
      if child:id() == section:id() then
        current_idx = #siblings
      end
    end
  end

  return siblings, current_idx
end

--- Get lines from the buffer for a section's range.
--- Uses 1-indexed lines from get_section_range and returns them along with
--- the 0-indexed start/end suitable for nvim_buf_set_lines.
---@param bufnr number  Buffer number
---@param section TSNode  The section node
---@return string[] lines  The text lines
---@return number start_0  0-indexed start row
---@return number end_0    0-indexed end row (exclusive for set_lines)
local function get_section_lines(bufnr, section)
  local start_line, end_line = ts.get_section_range(section)
  local start_0 = start_line - 1
  local end_0 = end_line
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_0, end_0, false)
  return lines, start_0, end_0
end

--- Move the current subtree up, swapping it with its previous sibling.
--- Adjusts cursor to follow the moved heading.
function M.move_subtree_up()
  local bufnr = 0
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1]

  local section = ts.get_section_at_line(bufnr, line)
  if not section then
    vim.notify('No section found at current line', vim.log.levels.WARN)
    return
  end

  local siblings, idx = find_siblings(section)
  if not idx or idx <= 1 then
    vim.notify('No previous sibling to swap with', vim.log.levels.WARN)
    return
  end

  local prev_section = siblings[idx - 1]

  local cur_lines, cur_start, cur_end = get_section_lines(bufnr, section)
  local prev_lines, prev_start, prev_end = get_section_lines(bufnr, prev_section)

  -- Calculate cursor offset within the current section
  local cursor_offset = cursor[1] - (cur_start + 1) -- offset from section start (1-indexed)

  -- Replace the entire range covering both sections with swapped content
  -- prev_start is the beginning of the earlier section (0-indexed)
  -- cur_end is the end of the later section (0-indexed, exclusive)
  local combined = {}
  for _, l in ipairs(cur_lines) do
    combined[#combined + 1] = l
  end
  for _, l in ipairs(prev_lines) do
    combined[#combined + 1] = l
  end

  vim.api.nvim_buf_set_lines(bufnr, prev_start, cur_end, false, combined)

  -- Adjust cursor: the current section now starts where prev_section was
  local new_cursor_line = prev_start + 1 + cursor_offset
  vim.api.nvim_win_set_cursor(0, { new_cursor_line, cursor[2] })

  update_folds()
end

--- Move the current subtree down, swapping it with its next sibling.
--- Adjusts cursor to follow the moved heading.
function M.move_subtree_down()
  local bufnr = 0
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1]

  local section = ts.get_section_at_line(bufnr, line)
  if not section then
    vim.notify('No section found at current line', vim.log.levels.WARN)
    return
  end

  local siblings, idx = find_siblings(section)
  if not idx or idx >= #siblings then
    vim.notify('No next sibling to swap with', vim.log.levels.WARN)
    return
  end

  local next_section = siblings[idx + 1]

  local cur_lines, cur_start, cur_end = get_section_lines(bufnr, section)
  local next_lines, next_start, next_end = get_section_lines(bufnr, next_section)

  -- Calculate cursor offset within the current section
  local cursor_offset = cursor[1] - (cur_start + 1)

  -- Replace the entire range covering both sections with swapped content
  local combined = {}
  for _, l in ipairs(next_lines) do
    combined[#combined + 1] = l
  end
  for _, l in ipairs(cur_lines) do
    combined[#combined + 1] = l
  end

  vim.api.nvim_buf_set_lines(bufnr, cur_start, next_end, false, combined)

  -- Adjust cursor: the current section now starts after the next section's lines
  local new_cursor_line = cur_start + 1 + #next_lines + cursor_offset
  vim.api.nvim_win_set_cursor(0, { new_cursor_line, cursor[2] })

  update_folds()
end

return M
