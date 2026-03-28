local M = {} -- define a table to hold our module

M.servers = {
  'bash', 'html', 'json', 'markdown', 'python', 'rust', 'sql', 'toml', 'tsx', 'typst', 'typescript' }

-- Return the module table so that it can be required by other scripts
return M
