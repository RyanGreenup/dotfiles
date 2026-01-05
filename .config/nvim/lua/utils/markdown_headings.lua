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

local function get_treesitter_type()
  local node = vim.treesitter.get_node()
  if node == nil then
    return nil
  end
  local type = node:type()
  print(type)
  return type
end

local function get_heading_level()
  local current_location = vim.api.nvim_win_get_cursor(0)
  -- Move cursor to the beginning of the line
  vim.api.nvim_win_set_cursor(0, { current_location[1], 0 })
  local ts_type = get_treesitter_type()
  -- Move cursor back
  vim.api.nvim_win_set_cursor(0, current_location)
  if ts_type ~= nil then
    local header_levels = {
      atx_h1_marker = 1,
      atx_h2_marker = 2,
      atx_h3_marker = 3,
      atx_h4_marker = 4,
      atx_h5_marker = 5,
      atx_h6_marker = 6,
    }

    return header_levels[ts_type] or nil -- set h_level to the corresponding value from map or nil if not found
  end
  return nil
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

    h_level = get_heading_level() or 0

    if h_level > 0 then
      break
    end
  end

  -- Restore cursor
  vim.api.nvim_win_set_cursor(0, current_location)

  -- Decide the heading level
  -- if h_level == 0 then
  --   print("No heading found")
  --   return
  if demote then
    h_level = h_level + 1
  end
  if h_level > 6 then
    h_level = 6
  end

  -- TODO use vim.api.nvim_buf_set_lines(0, location_for_insert[1], location_for_insert[1], false, {string.rep("#", h_level) .. " "})
  -- To set the heading below headings of a lesser level
  -- Insert the heading
  -- check if the current line is empty
  local current_line_text = api.nvim_get_current_line()
  if current_line_text ~= "" then
    vim.cmd("normal! o")
  end
  api.nvim_set_current_line(string.rep("#", h_level) .. " ")
end

local function heading_promotion(decrease)
  if decrease == nil then
    decrease = false
  end
  -- Move cursor to the start of the line where heading is
  vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], 0 })
  local h_level = get_heading_level()
  if h_level == nil then
    print("No heading found")
    return
  end
  local current_line = vim.api.nvim_get_current_line()
  if not decrease then
    if h_level == 1 then
      print("Cannot decrease heading level below 1")
      return
    else
      -- Remove one # from the start of the line
      vim.api.nvim_set_current_line(current_line:sub(2))
    end
  else
    if h_level == 6 then
      print("Cannot decrease heading level above 6")
      return
    else
      -- Add one # to the start of the line
      vim.api.nvim_set_current_line("#" .. current_line)
    end
  end
end

local function heading_promotion_all_below(demote)
  if demote == nil then
    demote = true
  end
  local current_location = vim.api.nvim_win_get_cursor(0)
  local current_line = current_location[1]
  local current_h_level = get_heading_level()
  if current_h_level == nil then
    print("No heading found")
    return
  end

  -- Promote the current heading
  local h_level = get_heading_level() or 0
  if h_level ~= 0 then
    heading_promotion(demote)
  end


  -- Loop forward through the lines
  h_level = 0
  for i = current_line + 1, vim.api.nvim_buf_line_count(0), 1 do
    -- Move cursor down
    vim.api.nvim_win_set_cursor(0, { i, 0 })
    -- Get the heading level
    h_level = get_heading_level() or 0

    if h_level ~= 0 then
      local test = current_h_level >= h_level
      -- If we hit a heading above we are done
      if test then
        print(current_h_level .. " >= " .. h_level .. " STOP")
        -- Restore cursor
        vim.api.nvim_win_set_cursor(0, current_location)
        return
      else
        -- Otherwise demote this heading
        heading_promotion(demote)
      end
    end
  end

  -- Restore cursor
  vim.api.nvim_win_set_cursor(0, current_location)
end

local function update_folds()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("zx", true, false, true), 'n', false)
end

function M.promote_all_headings_below()
  heading_promotion_all_below(false)
end

function M.demote_all_headings_below()
  heading_promotion_all_below(true)
  update_folds()
end

function M.demote_heading()
  heading_promotion(false)
  update_folds()
end

function M.promote_heading()
  heading_promotion(true)
  update_folds()
end

function M.insert_heading_below()
  Insert_markdown_heading_below(false)
  update_folds()
end

function M.insert_subheading_below()
  Insert_markdown_heading_below(true)
  update_folds()
end

function M.get_treesitter_type()
  print(get_treesitter_type())
end

---Creates a title from a file path
---@param path string
---@return string
function M.make_title(path)
  local title ---@type string: The title to return
  local base_no_ext ---@type string: Base name without extension
  -- basename
  base_no_ext = vim.fn.fnamemodify(path, ":t:r")
  -- Change extensions etc.
  title = base_no_ext:gsub("-", " "):gsub("_", " / ")
  -- title case
  title = title:gsub("(%a)([%w_']*)", function(first, rest)
    return first:upper() .. rest:lower()
  end)
  return title
end

---Creates a markdown link from a file path
---@param path string: the target path to the file
---@return string: A markdown link with a formatted title
function M.make_markdown_link(path)
  return "[" .. M.make_title(path) .. "](" .. path .. ")"
end

return M
