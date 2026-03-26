--- Narrow-to-subtree and widen for markdown buffers.
--- Restricts the visible buffer to the current heading's section by folding
--- everything outside it, then restores the full view on widen.
local M = {}

local ts = require('orgmark.treesitter')

--- Narrow the view to the section containing the cursor.
--- Folds everything outside the current section's range, leaving only the
--- target subtree visible. Stores state in buffer-local variables so that
--- `widen()` can restore the previous view.
function M.narrow_to_subtree()
  local bufnr = 0
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1]

  local section = ts.get_section_at_line(bufnr, line)
  if not section then
    vim.api.nvim_echo({ { 'orgmark: no section found at cursor', 'WarningMsg' } }, false, {})
    return
  end

  local start_line, end_line = ts.get_section_range(section)

  -- Get the heading text for the echo message
  local heading = ts.get_heading_at_line(bufnr, line)
  local heading_text = ''
  if heading then
    local row = heading:start()
    heading_text = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ''
  end

  -- Save fold state so we can restore later
  vim.b.orgmark_narrow_state = {
    foldmethod = vim.wo.foldmethod,
    foldlevel = vim.wo.foldlevel,
    foldenable = vim.wo.foldenable,
  }

  -- Close all folds first
  vim.cmd('silent! normal! zM')

  local total_lines = vim.api.nvim_buf_line_count(bufnr)

  -- Fold everything above the section
  if start_line > 1 then
    vim.cmd(string.format('silent! 1,%dfold', start_line - 1))
  end

  -- Fold everything below the section
  if end_line < total_lines then
    vim.cmd(string.format('silent! %d,%dfold', end_line + 1, total_lines))
  end

  -- Open folds within the section range so content is visible
  vim.api.nvim_win_set_cursor(0, { start_line, 0 })
  vim.cmd('silent! normal! zO')

  -- Restore cursor position (clamped to section range)
  local target_line = math.max(start_line, math.min(line, end_line))
  vim.api.nvim_win_set_cursor(0, { target_line, cursor[2] })

  vim.b.orgmark_narrowed = true

  vim.api.nvim_echo({ { 'Narrowed to: ' .. heading_text, 'Normal' } }, false, {})
end

--- Restore the full buffer view after narrowing.
--- Opens all folds and clears the narrowed state.
function M.widen()
  if not vim.b.orgmark_narrowed then
    vim.api.nvim_echo({ { 'orgmark: buffer is not narrowed', 'WarningMsg' } }, false, {})
    return
  end

  -- Open all folds to restore visibility
  vim.cmd('silent! normal! zR')

  -- Recompute folds to get back to the proper treesitter-based folding
  vim.cmd('silent! normal! zx')

  vim.b.orgmark_narrowed = nil
  vim.b.orgmark_narrow_state = nil

  vim.api.nvim_echo({ { 'Widened', 'Normal' } }, false, {})
end

return M
