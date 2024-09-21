local M = {} -- define a table to hold our module

local opts = require("dokuwiki/config")

function M.edit_link_under_cursor()
  local link = require('dokuwiki/links').get_link_under_cursor()
  vim.cmd("edit " .. link)
end

-- Return the module table so that it can be required by other scripts
return M
