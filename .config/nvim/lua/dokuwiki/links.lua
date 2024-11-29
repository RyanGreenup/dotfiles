local M = {} -- define a table to hold our module

-- todo if current dir is under the dokuwiki dir, need to treat relatively
local get_link_under_cursor = function()
  local pos = vim.api.nvim_win_get_cursor(0)
  -- local y = pos[1]
  local x = pos[2]
  local current_line = vim.api.nvim_get_current_line()
  local line_length = vim.fn.strdisplaywidth(vim.api.nvim_get_current_line())


  -- Where is the first square bracket
  local bounds = { 0, 0 }
  for i = x, 1, -1 do
    if current_line:sub(i, i) == "[" then
      -- One more than the [
      bounds[1] = i + 1
      break
    end
  end

  for i = x, line_length + 1 do
    if current_line:sub(i, i) == "]" or current_line:sub(i, i) == "|" then
      -- One less than the ]
      bounds[2] = i - 1
      break
    end
  end
  local link = current_line:sub(bounds[1], bounds[2])

  -- Handle Absolute and relative paths
  local is_abs = false
  if link:sub(1, 1) == ":" then
    is_abs = true
    -- Drop the leading / as it will be appended to a path
    link = link:sub(2)
  end
  -- No : for up dir at the beginning
  -- put one in for the later sed
  if link:sub(1, 2) == ".." then
    link = "..:" .. link:sub(3)
  end
  if link:sub(1, 1) == "." and link:sub(2, 2) ~= "." then
    link = link:sub(2)
  end

  -- Swap : for /
  link = link:gsub(":", "/")

  local create_file_path = function(dir, l)
    return dir .. "/" .. l .. ".txt"
  end

  -- If it's a relativee link, instead consider this approach
  local current_dir = vim.fn.expand("%:p:h")
  vim.fn.resolve(current_dir)
  if not is_abs and current_dir:find(require('dokuwiki/config').dokuwiki_directory) then
    link = create_file_path(current_dir, link)
  else
    -- get the link by concatenating the dokuwiki directory and the link
    link = create_file_path(require('dokuwiki/config').dokuwiki_directory, link)

  end

  return link
end


function M.edit_link_under_cursor()
  local link = get_link_under_cursor()
  vim.cmd("edit " .. link)
end

-- Return the module table so that it can be required by other scripts
return M
