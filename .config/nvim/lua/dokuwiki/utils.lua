
local M = {} -- define a table to hold our module


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

---@return string The path to Dokuwiki's directory containing pages.
function M.dokuwiki_directory()
  local dir = get_home() .. "/Applications/Docker/dokuwiki/data/pages"
  -- Resolve symlinks
  return vim.fn.resolve(dir)
end

-- Return the module table so that it can be required by other scripts
return M
