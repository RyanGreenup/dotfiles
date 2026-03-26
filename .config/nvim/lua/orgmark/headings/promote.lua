--- Heading promotion and demotion operations.
--- Supports single-heading and subtree (all children) variants.
local M = {}

local ts = require('orgmark.treesitter')

--- Recompute folds after a heading modification.
local function update_folds()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('zx', true, false, true), 'n', false)
end

--- Promote (decrease level) the heading on the current line.
--- Removes one `#` from the heading marker. Minimum level is 1.
function M.promote_heading()
  local bufnr = 0
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1] -- 1-indexed
  local col = cursor[2]

  local heading = ts.get_heading_at_line(bufnr, line)
  if not heading then
    vim.notify('No heading found at current line', vim.log.levels.WARN)
    return
  end

  local level = ts.get_heading_level(heading)
  if not level or level <= 1 then
    vim.notify('Cannot promote heading beyond level 1', vim.log.levels.WARN)
    return
  end

  -- The heading node's start line (0-indexed)
  local heading_row = heading:start()
  local lines = vim.api.nvim_buf_get_lines(bufnr, heading_row, heading_row + 1, false)
  if #lines == 0 then
    return
  end

  local text = lines[1]
  -- Remove exactly one leading '#'
  local new_text = text:gsub('^#', '', 1)
  vim.api.nvim_buf_set_lines(bufnr, heading_row, heading_row + 1, false, { new_text })

  -- Preserve cursor column, adjusting for the removed character
  local new_col = math.max(0, col - 1)
  vim.api.nvim_win_set_cursor(0, { cursor[1], new_col })

  update_folds()
end

--- Demote (increase level) the heading on the current line.
--- Adds one `#` to the heading marker. Maximum level is 6.
function M.demote_heading()
  local bufnr = 0
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1]
  local col = cursor[2]

  local heading = ts.get_heading_at_line(bufnr, line)
  if not heading then
    vim.notify('No heading found at current line', vim.log.levels.WARN)
    return
  end

  local level = ts.get_heading_level(heading)
  if not level or level >= 6 then
    vim.notify('Cannot demote heading beyond level 6', vim.log.levels.WARN)
    return
  end

  local heading_row = heading:start()
  local lines = vim.api.nvim_buf_get_lines(bufnr, heading_row, heading_row + 1, false)
  if #lines == 0 then
    return
  end

  local text = lines[1]
  local new_text = '#' .. text
  vim.api.nvim_buf_set_lines(bufnr, heading_row, heading_row + 1, false, { new_text })

  -- Preserve cursor column, adjusting for the added character
  vim.api.nvim_win_set_cursor(0, { cursor[1], col + 1 })

  update_folds()
end

--- Promote the current heading and all child headings in its subtree.
--- Skips headings already at level 1.
function M.promote_subtree()
  local bufnr = 0
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1]

  local section = ts.get_section_at_line(bufnr, line)
  if not section then
    vim.notify('No section found at current line', vim.log.levels.WARN)
    return
  end

  local heading = ts.get_heading_at_line(bufnr, line)
  if not heading then
    vim.notify('No heading found at current line', vim.log.levels.WARN)
    return
  end

  local start_line, end_line = ts.get_section_range(section)

  -- Collect all headings within the section range
  local all_headings = ts.get_all_headings(bufnr)
  -- Process in reverse order so line numbers remain valid after edits
  local to_promote = {}
  for _, h in ipairs(all_headings) do
    if h.line >= start_line and h.line <= end_line and h.level > 1 then
      to_promote[#to_promote + 1] = h
    end
  end

  -- Sort descending by line so modifications don't shift later lines
  table.sort(to_promote, function(a, b) return a.line > b.line end)

  for _, h in ipairs(to_promote) do
    local row = h.line - 1 -- 0-indexed
    local lines = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)
    if #lines > 0 then
      local new_text = lines[1]:gsub('^#', '', 1)
      vim.api.nvim_buf_set_lines(bufnr, row, row + 1, false, { new_text })
    end
  end

  -- Adjust cursor column for the heading line promotion
  local new_col = math.max(0, cursor[2] - 1)
  vim.api.nvim_win_set_cursor(0, { cursor[1], new_col })

  update_folds()
end

--- Demote the current heading and all child headings in its subtree.
--- Skips headings already at level 6.
function M.demote_subtree()
  local bufnr = 0
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1]

  local section = ts.get_section_at_line(bufnr, line)
  if not section then
    vim.notify('No section found at current line', vim.log.levels.WARN)
    return
  end

  local heading = ts.get_heading_at_line(bufnr, line)
  if not heading then
    vim.notify('No heading found at current line', vim.log.levels.WARN)
    return
  end

  local start_line, end_line = ts.get_section_range(section)

  local all_headings = ts.get_all_headings(bufnr)
  local to_demote = {}
  for _, h in ipairs(all_headings) do
    if h.line >= start_line and h.line <= end_line and h.level < 6 then
      to_demote[#to_demote + 1] = h
    end
  end

  -- Sort descending by line so modifications don't shift later lines
  table.sort(to_demote, function(a, b) return a.line > b.line end)

  for _, h in ipairs(to_demote) do
    local row = h.line - 1
    local lines = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)
    if #lines > 0 then
      local new_text = '#' .. lines[1]
      vim.api.nvim_buf_set_lines(bufnr, row, row + 1, false, { new_text })
    end
  end

  vim.api.nvim_win_set_cursor(0, { cursor[1], cursor[2] + 1 })

  update_folds()
end

return M
