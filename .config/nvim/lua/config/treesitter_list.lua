local M = {} -- define a table to hold our module

M.servers = {
  'markdown', 'sql', 'python', 'rust', 'typst' }

-- Return the module table so that it can be required by other scripts
return M
