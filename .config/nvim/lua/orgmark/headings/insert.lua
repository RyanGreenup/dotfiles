--- Insert new headings (sibling or child) in a markdown buffer.
local M = {}

local ts = require('orgmark.treesitter')

--- Recompute folds after a heading modification.
local function update_folds()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('zx', true, false, true), 'n', false)
end

--- Find the heading level for the current context.
--- If the cursor is not on a heading, walks backwards through the buffer to find
--- the nearest heading above.
---@param bufnr number  Buffer number (0 for current)
---@param line number   1-indexed current line
---@return number level  The heading level (1 if no heading found)
local function find_context_level(bufnr, line)
  -- First try the heading at the current line (walks up tree)
  local heading = ts.get_heading_at_line(bufnr, line)
  if heading then
    local level = ts.get_heading_level(heading)
    if level then
      return level
    end
  end

  -- Walk backwards through all headings to find the nearest one above
  local all_headings = ts.get_all_headings(bufnr)
  for i = #all_headings, 1, -1 do
    if all_headings[i].line <= line then
      return all_headings[i].level
    end
  end

  return 1
end

--- Insert a sibling heading at the same level as the current heading.
--- Places the new heading at the end of the current section.
--- If no heading is found, defaults to level 1.
--- Enters insert mode after insertion.
function M.insert_sibling_heading()
  local bufnr = 0
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1]

  local level = find_context_level(bufnr, line)
  local marker = string.rep('#', level) .. ' '

  -- Find the end of the current section to insert after it
  local section = ts.get_section_at_line(bufnr, line)
  local insert_line
  if section then
    local _, end_line = ts.get_section_range(section)
    insert_line = end_line
  else
    insert_line = line
  end

  -- Build lines to insert
  local lines_to_insert = {}

  -- Check if the preceding line is empty; add blank line if it is not
  local preceding = vim.api.nvim_buf_get_lines(bufnr, insert_line - 1, insert_line, false)
  if #preceding > 0 and preceding[1] ~= '' then
    lines_to_insert[#lines_to_insert + 1] = ''
  end

  lines_to_insert[#lines_to_insert + 1] = marker

  vim.api.nvim_buf_set_lines(bufnr, insert_line, insert_line, false, lines_to_insert)

  -- Move cursor to the end of the new heading marker
  local new_line = insert_line + #lines_to_insert
  vim.api.nvim_win_set_cursor(0, { new_line, #marker })

  update_folds()

  -- Enter insert mode (append at end of line)
  vim.cmd('startinsert!')
end

--- Insert a child heading one level deeper than the current heading.
--- Places the new heading directly below the current line.
--- Level is capped at 6.
--- Enters insert mode after insertion.
function M.insert_child_heading()
  local bufnr = 0
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1]

  local level = find_context_level(bufnr, line)
  local child_level = math.min(level + 1, 6)
  local marker = string.rep('#', child_level) .. ' '

  -- Insert directly below current line
  local insert_after = line

  local lines_to_insert = {}

  -- Check if the current line is empty; add blank line if it is not
  local current = vim.api.nvim_buf_get_lines(bufnr, insert_after - 1, insert_after, false)
  if #current > 0 and current[1] ~= '' then
    lines_to_insert[#lines_to_insert + 1] = ''
  end

  lines_to_insert[#lines_to_insert + 1] = marker

  vim.api.nvim_buf_set_lines(bufnr, insert_after, insert_after, false, lines_to_insert)

  -- Move cursor to end of new heading marker
  local new_line = insert_after + #lines_to_insert
  vim.api.nvim_win_set_cursor(0, { new_line, #marker })

  update_folds()

  -- Enter insert mode
  vim.cmd('startinsert!')
end

return M
