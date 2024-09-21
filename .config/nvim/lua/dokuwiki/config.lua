local M = {} -- define a table to hold our module

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
    if current_line:sub(i, i) == "]" then
      -- One less than the ]
      bounds[2] = i - 1
      break
    end
  end
  local link = current_line:sub(bounds[1], bounds[2])


  link = link:gsub(":", "/")
  if link:sub(1, 1) == "/" then
    link = link:sub(2)
  end
  link = M.dokuwiki_directory() .. "/" .. link .. ".txt"
  return link
end

-- TODO Find a place to store all config settings
-- TODO refactor this into a plugin
---@return string The path to Dokuwiki's directory containing pages.
function M.dokuwiki_directory()
  return "~/Applications/Docker/dokuwiki/data/pages"
end

function M.edit_link_under_cursor()
  local link = get_link_under_cursor()
  vim.cmd("edit " .. link)
end

-- Return the module table so that it can be required by other scripts
return M
