--- Configuration management for orgmark.
--- Holds default values and handles deep-merging of user overrides.
local M = {}

--- Default configuration table.
--- Submodules reference `M.current` after setup has run.
---@type table
M.defaults = {
  filetypes = { 'markdown', 'mdx' },
  folding = {
    startup_folded = 'content', -- 'overview' | 'content' | 'showeverything'
    ellipsis = '…',
    show_line_count = true,
  },
  -- Placeholder sections for future modules
  headings = {},
  todo = {},
  lists = {},
  timestamps = {},
}

--- Active (merged) configuration. Nil until `setup()` is called.
---@type table
M.current = vim.deepcopy(M.defaults)

--- Deep-merge user options over defaults and store the result.
---@param opts? table  User-provided configuration overrides
---@return table  The merged configuration
function M.setup(opts)
  M.current = vim.tbl_deep_extend('force', vim.deepcopy(M.defaults), opts or {})
  return M.current
end

return M
