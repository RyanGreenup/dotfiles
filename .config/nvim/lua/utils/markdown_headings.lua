local M = {}

--[[
This module Allows the user to insert a markdown heading of the correct
level below the current line. This is useful for creating a new section
in documentation similar to org-mode

The user may wish to bind this to a keymap like so:

```lua
vim.api.nvim_create_autocmd({ 'FileType' }, {
  pattern = 'markdown',
  callback = function()
    map('n', '<C-CR>', '',
      {
        callback = function()
          require('utils/markdown_headings').insert_subheading_below()
        end,
        noremap = true,
        silent = true,
        desc =
        "Use Treesitter to Insert a Markdown Heading of the right level"
      })
  end,
})
```
--]]

local function get_tresitter_type()
  -- local current_location = vim.api.nvim_win_get_cursor(0)
  -- local current_line = current_location[1]
  -- local current_col = current_location[2]
  -- local lang_tree = vim.treesitter.get_parser(buf_num) -- Defaults to current filetype
  -- local root_node = ts_utils.get_root_for_position(current_line, current_col, lang_tree)

  local ts_utils = require('nvim-treesitter.ts_utils')
  local buf_num = 0 -- your buffer number (replace with appropriate value)
  local root_node = ts_utils.get_node_at_cursor(0)
  if root_node == nil then
    return nil
  end
  local type = root_node:type()
  print(type)
  return type
end


-- Insert a markdown heading below the current line
-- This heading will be the correct Depth
local function Insert_markdown_heading_below(demote)
  local api = vim.api
  local current_location = api.nvim_win_get_cursor(0)
  local current_line = current_location[1]

  -- Loop backwards for the start of the code block
  local h_level = 0
  for i = current_line, 1, -1 do
    -- TODO test if I need to be below
    vim.api.nvim_win_set_cursor(0, { i, 0 })
    local ts_type = get_tresitter_type()
    if ts_type ~= nil then
      if ts_type == "atx_h1_marker" then
        h_level = 1
      elseif ts_type == "atx_h2_marker" then
        h_level = 2
      elseif ts_type == "atx_h3_marker" then
        h_level = 3
      elseif ts_type == "atx_h4_marker" then
        h_level = 4
      elseif ts_type == "atx_h5_marker" then
        h_level = 5
      elseif ts_type == "atx_h6_marker" then
        h_level = 6
      end
    end

    if h_level > 0 then
      break
    end
  end

  -- Restore cursor
  vim.api.nvim_win_set_cursor(0, current_location)

  -- Decide the heading level
  if h_level == 0 then
    print("No heading found")
    return
  elseif demote then
    h_level = h_level + 1
  end
  if h_level > 6 then
    h_level = 6
  end

  -- Insert the heading
  -- check if the current line is empty
  local current_line_text = api.nvim_get_current_line()
  if current_line_text ~= "" then
    vim.cmd("normal! o")
  end
  api.nvim_set_current_line(string.rep("#", h_level) .. " ")
end

function M.insert_heading_below()
  Insert_markdown_heading_below(false)
end

function M.insert_subheading_below()
  Insert_markdown_heading_below(true)
end

return M
