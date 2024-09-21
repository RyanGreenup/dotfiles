local M = {} -- define a table to hold our module

-- TODO Find a place to store all config settings
-- TODO refactor this into a plugin
---@return string The path to Dokuwiki's directory containing pages.
function M.dokuwiki_directory()
  local dir = get_home() .. "/Applications/Docker/dokuwiki/data/pages"
  -- Resolve symlinks
  return vim.fn.resolve(dir)
end

---@return string The path to the user's home directory.
local function get_home()
  local home = os.getenv("HOME")
  if home == nil then
    -- check if plenary is available
    if pcall(function() require("plenary.path") end) then
      home = require("plenary.path").new({ "~" }):expand()
    else
      home = "~"
    end
  end
  return home
end

-- TODO Find a place to store all config settings
-- TODO refactor this into a plugin
---@return string The path to Dokuwiki's directory containing pages.
function M.dokuwiki_directory()
  local dir = get_home() .. "/Applications/Docker/dokuwiki/data/pages"
  -- Resolve symlinks
  return vim.fn.resolve(dir)
end

function M.edit_link_under_cursor()
  local link = get_link_under_cursor()
  vim.cmd("edit " .. link)
end

-- Return the module table so that it can be required by other scripts
return M
