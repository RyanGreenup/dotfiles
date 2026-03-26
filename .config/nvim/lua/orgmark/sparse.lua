--- Sparse tree views for markdown buffers.
--- Shows only headings matching a search pattern or keyword, with their parent
--- hierarchy visible, while keeping everything else folded.
local M = {}

local ts = require('orgmark.treesitter')

--- Open the fold at a given 1-indexed line, plus all ancestor folds
--- so the line becomes visible.
---@param line number  1-indexed line number to reveal
local function reveal_line(line)
  -- Move cursor to the target line to operate on its folds
  vim.api.nvim_win_set_cursor(0, { line, 0 })
  -- Open folds at this line recursively (in case of nested folds)
  -- Use a loop: keep opening until the line is no longer in a closed fold
  local max_iterations = 20
  for _ = 1, max_iterations do
    local fold_start = vim.fn.foldclosed(line)
    if fold_start == -1 then
      break -- line is visible
    end
    -- Open the fold that contains this line
    vim.api.nvim_win_set_cursor(0, { fold_start, 0 })
    vim.cmd('silent! normal! zo')
  end
end

--- Build a set of lines that need to be revealed for a list of matching headings.
--- For each match, includes the heading line itself and all parent heading lines
--- so the structural hierarchy is visible.
---@param matches { line: number, level: number }[]  The matching headings
---@param all_headings { node: TSNode, level: number, line: number, text: string }[]  All headings in the buffer
---@return number[] lines  Sorted, deduplicated list of 1-indexed lines to reveal
local function collect_lines_to_reveal(matches, all_headings)
  local line_set = {}

  for _, match in ipairs(matches) do
    line_set[match.line] = true

    -- Walk backwards through all_headings to find ancestors
    -- An ancestor is a heading with a lower level that appears before this one
    local target_level = match.level
    for i = #all_headings, 1, -1 do
      local h = all_headings[i]
      if h.line < match.line and h.level < target_level then
        line_set[h.line] = true
        target_level = h.level
        if target_level <= 1 then
          break -- reached the top level
        end
      end
    end
  end

  -- Convert set to sorted list
  local lines = {}
  for l in pairs(line_set) do
    lines[#lines + 1] = l
  end
  table.sort(lines)
  return lines
end

--- Perform a sparse tree operation: close all folds, then reveal matching headings.
---@param bufnr number  Buffer number (0 for current)
---@param filter fun(heading: { node: TSNode, level: number, line: number, text: string }): boolean
---@return number count  Number of matches found
local function sparse_filter(bufnr, filter)
  local all_headings = ts.get_all_headings(bufnr)

  -- Collect matches
  local matches = {}
  for _, h in ipairs(all_headings) do
    if filter(h) then
      matches[#matches + 1] = h
    end
  end

  -- Save cursor position
  local cursor = vim.api.nvim_win_get_cursor(0)

  -- Close all folds
  vim.cmd('silent! normal! zM')

  if #matches == 0 then
    -- Restore cursor
    pcall(vim.api.nvim_win_set_cursor, 0, cursor)
    return 0
  end

  -- Collect all lines that need to be visible (matches + ancestors)
  local lines_to_reveal = collect_lines_to_reveal(matches, all_headings)

  -- Reveal each line
  for _, line in ipairs(lines_to_reveal) do
    reveal_line(line)
  end

  -- Move cursor to the first match
  vim.api.nvim_win_set_cursor(0, { matches[1].line, 0 })

  return #matches
end

--- Prompt for a search pattern and show only matching headings.
--- All other content is folded away. Matching is case-insensitive.
function M.search()
  local pattern = vim.fn.input('Sparse tree: ')
  if not pattern or pattern == '' then
    return
  end

  -- Escape the pattern for case-insensitive Lua matching is tricky,
  -- so we use string.lower comparison instead
  local lower_pattern = pattern:lower()

  local count = sparse_filter(0, function(h)
    return h.text:lower():find(lower_pattern, 1, true) ~= nil
  end)

  vim.api.nvim_echo({ { count .. ' match' .. (count == 1 and '' or 'es') .. ' found', 'Normal' } }, false, {})
end

--- Show only headings with TODO or DOING keywords.
--- Everything else is folded away.
function M.show_todos()
  local todo = require('orgmark.todo')
  local count = sparse_filter(0, function(h)
    local _, keyword = todo.parse_heading(h.text)
    return keyword == 'TODO' or keyword == 'DOING'
  end)

  vim.api.nvim_echo({ { count .. ' TODO' .. (count == 1 and '' or 's') .. ' found', 'Normal' } }, false, {})
end

--- Show only headings with the DONE keyword.
--- Everything else is folded away.
function M.show_done()
  local todo = require('orgmark.todo')
  local count = sparse_filter(0, function(h)
    local _, keyword = todo.parse_heading(h.text)
    return keyword == 'DONE'
  end)

  vim.api.nvim_echo({ { count .. ' DONE item' .. (count == 1 and '' or 's') .. ' found', 'Normal' } }, false, {})
end

return M
