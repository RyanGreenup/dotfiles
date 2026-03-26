--- Link insertion and editing for markdown buffers.
--- Provides smart link creation: inserts `[text](url)` at cursor,
--- wraps visual selections, and edits existing links in-place.
local M = {}

--- Pattern to detect a markdown link: [text](url)
---@type string
local LINK_PAT = '%[([^%]]*)%]%(([^%)]*)?%)'

--- Detect if the cursor is on an existing markdown link.
--- Returns the match boundaries and captures if found.
---@param line string  The line text
---@param col number   0-indexed cursor column
---@return number|nil start  1-indexed start of the link
---@return number|nil finish 1-indexed end of the link
---@return string|nil text   The link text
---@return string|nil url    The link URL
local function find_link_at_cursor(line, col)
  -- Search for all links on the line and check if cursor falls within one
  local search_start = 1
  while true do
    local s, e, text, url = line:find('%[([^%]]*)%]%(([^%)]*)%)', search_start)
    if not s then
      break
    end
    -- col is 0-indexed, s and e are 1-indexed
    if col >= (s - 1) and col < e then
      return s, e, text, url
    end
    search_start = e + 1
  end
  return nil, nil, nil, nil
end

--- Insert or edit a markdown link.
--- If `visual` is true, uses the visual selection as the link text.
--- If cursor is on an existing link, offers to edit it.
--- Otherwise prompts for both text and URL.
---@param visual? boolean  Whether to use visual selection as link text
function M.smart_link(visual)
  local bufnr = 0
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1]
  local col = cursor[2]
  local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1]
  if not line then
    return
  end

  -- Check if we're on an existing link
  local s, e, existing_text, existing_url = find_link_at_cursor(line, col)

  if s and e then
    -- Editing an existing link
    local new_text = vim.fn.input('Link text: ', existing_text)
    if new_text == '' then
      return
    end
    local new_url = vim.fn.input('URL: ', existing_url)
    if new_url == '' then
      return
    end

    local new_link = '[' .. new_text .. '](' .. new_url .. ')'
    local before = line:sub(1, s - 1)
    local after = line:sub(e + 1)
    vim.api.nvim_buf_set_lines(bufnr, row - 1, row, false, { before .. new_link .. after })
    return
  end

  -- Creating a new link
  local link_text = ''

  if visual then
    -- Get visual selection
    -- Exit visual mode first to update marks
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'nx', false)
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    local start_row, start_col = start_pos[2], start_pos[3]
    local end_row, end_col = end_pos[2], end_pos[3]

    if start_row == end_row then
      local sel_line = vim.api.nvim_buf_get_lines(bufnr, start_row - 1, start_row, false)[1]
      link_text = sel_line:sub(start_col, end_col)
      -- Remove the selected text and insert link in its place
      local before_sel = sel_line:sub(1, start_col - 1)
      local after_sel = sel_line:sub(end_col + 1)

      local url = vim.fn.input('URL: ')
      if url == '' then
        return
      end

      local new_link = '[' .. link_text .. '](' .. url .. ')'
      vim.api.nvim_buf_set_lines(bufnr, start_row - 1, start_row, false, { before_sel .. new_link .. after_sel })
      return
    end
  end

  -- Prompt for link text if not from visual selection
  if link_text == '' then
    link_text = vim.fn.input('Link text: ')
    if link_text == '' then
      return
    end
  end

  local url = vim.fn.input('URL: ')
  if url == '' then
    return
  end

  local new_link = '[' .. link_text .. '](' .. url .. ')'

  -- Insert at cursor position
  local before = line:sub(1, col)
  local after = line:sub(col + 1)
  vim.api.nvim_buf_set_lines(bufnr, row - 1, row, false, { before .. new_link .. after })
  vim.api.nvim_win_set_cursor(0, { row, col + #new_link })
end

return M
