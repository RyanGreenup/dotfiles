local M = {} -- define a table to hold our module

-- Much of this is lifted or adapted from
-- ~/.config/nvim/lua/utils/markdown_headings.lua


local headings = {
  [2] = 5,
  [3] = 4,
  [4] = 3,
  [5] = 2,
  [6] = 1
}

local h_level_to_equals = {
  [1] = "======",
  [2] = "=====",
  [3] = "====",
  [4] = "===",
  [5] = "==",
}

local function get_heading_level(s)
  if s == nil then
    s = vim.api.nvim_get_current_line()
  end


  local len_all = #s
  local len_no_equals = #s:gsub("=", "")
  local len_equals = len_all - len_no_equals

  if len_equals % 2 ~= 0 then
    print("malformed heading")
    return nil
  elseif not (2 <= len_equals / 2 and len_equals / 2 <= 6) then
    print("Heading Level not in [2, 6]")
    return nil
  else
    len_equals = len_equals / 2
    return headings[len_equals]
  end
end


-- Increase Heading
local function increase_heading()
  local current_line = vim.api.nvim_get_current_line()

  -- If this is nil, the heading is invalid, so return
  local h_level = get_heading_level(current_line)
  if h_level == nil then
    return
  end

  -- Check if the heading can be increased
  if h_level == 1 then
    print("Cannot decrease heading level above 1")
    return
  end

  -- Increase the heading by adding equals
  local new_heading = "=" .. current_line .. "="
  vim.api.nvim_set_current_line(new_heading)
end

local function decrease_heading()
  local current_line = vim.api.nvim_get_current_line()

  -- If this is nil, the heading is invalid, so return
  local h_level = get_heading_level(current_line)
  if h_level == nil then
    return
  end

  -- Check if the heading can be increased
  if h_level == 5 then
    print("Cannot decrease heading level below 5 in Dokuwiki")
    return
  end

  -- Increase the heading by adding equals
  local new_heading = current_line:sub(2, -2)
  vim.api.nvim_set_current_line(new_heading)
end


local function heading_promotion(demote)
  if demote then
    decrease_heading()
  else
    increase_heading()
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

local function set_heading_level(h_level)
  -- Get current line
  local current_line = vim.api.nvim_get_current_line()
  -- check it's a vailid heading
  local current_h_level = get_heading_level(current_line)
  if current_h_level == nil then
    -- This is ok for an empty line
    if current_line ~= "" then
      print("Not a Valid Heading")
      return
    end
  end
  -- Remove all equals
  local new_heading = current_line:gsub("=", "")
  -- Remove leading and trailing whitespace
  new_heading = new_heading:sub(2, -2)
  -- Set the correct heading level
  local equals_string = h_level_to_equals[h_level]
  if equals_string == nil then
    print("Invalid heading level")
    return
  end
  new_heading = equals_string .. " " .. new_heading .. " " .. equals_string
  -- Set the new heading
  vim.api.nvim_set_current_line(new_heading)
end


local function Insert_markdown_heading_below(demote)
  print("B")
  local api = vim.api
  local current_location = api.nvim_win_get_cursor(0)
  local current_line = current_location[1]

  print("c")
  -- Loop backwards for the start of the code block
  local h_level = 0
  for i = current_line, 1, -1 do
    -- TODO test if I need to be below
    vim.api.nvim_win_set_cursor(0, { i, 0 })

    h_level = get_heading_level() or 0
    if h_level ~= nil then
      if h_level > 0 then
        break
      end
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
  set_heading_level(h_level)
end





-- Define the function we want to export

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
  decrease_heading()
  update_folds()
end

function M.promote_heading()
  increase_heading()
  update_folds()
end

function M.insert_heading_below()
  Insert_markdown_heading_below(false)
  update_folds()
end

function M.insert_subheading_below()
  print("A")
  Insert_markdown_heading_below(true)
  update_folds()
end

-- Return the module table so that it can be required by other scripts
return M
