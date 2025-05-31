local M = {} -- define a table to hold our module

M.servers = {
  'markdown', 'sql', 'python', 'rust', 'typst', 'typescript' }

-- Return the module table so that it can be required by other scripts
return M
