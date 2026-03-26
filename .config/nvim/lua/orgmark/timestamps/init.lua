--- Date and timestamp insertion for markdown buffers.
--- Provides functions to insert dates in org-mode-style angle-bracket format
--- or as plain text at the cursor position.
local M = {}

--- Insert text at the current cursor position.
--- Moves the cursor to the end of the inserted text.
---@param text string  The text to insert
local function insert_at_cursor(text)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ''
  local before = line:sub(1, col)
  local after = line:sub(col + 1)
  vim.api.nvim_buf_set_lines(0, row - 1, row, false, { before .. text .. after })
  vim.api.nvim_win_set_cursor(0, { row, col + #text })
end

--- Insert today's date in angle brackets at the cursor.
--- With a count prefix (e.g. `1<C-c>.`), includes time: `<2026-03-26 14:30>`.
--- Without a count, date only: `<2026-03-26>`.
function M.insert_date()
  local include_time = vim.v.count > 0
  local text
  if include_time then
    text = '<' .. os.date('%Y-%m-%d %H:%M') .. '>'
  else
    text = '<' .. os.date('%Y-%m-%d') .. '>'
  end
  insert_at_cursor(text)
end

--- Insert today's date as plain text (no angle brackets).
--- Format: `2026-03-26`
function M.insert_date_plain()
  insert_at_cursor(os.date('%Y-%m-%d'))
end

--- Insert a full timestamp with date and time in angle brackets.
--- Always includes time: `<2026-03-26 14:30>`.
function M.insert_timestamp()
  local text = '<' .. os.date('%Y-%m-%d %H:%M') .. '>'
  insert_at_cursor(text)
end

return M
