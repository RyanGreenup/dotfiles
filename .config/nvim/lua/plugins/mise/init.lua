--- Mise integration: treesitter injections, LSP schema, and otter.nvim.
---
--- Files:
---   settings.lua                       - taplo schema association for mise TOML
---   after/queries/toml/injections.scm  - bash/shebang injection in run strings
---   after/queries/bash/injections.scm  - TOML/KDL injection in #MISE/#USAGE comments
---   after/queries/python/injections.scm - same as bash, for Python file tasks

-- Custom treesitter predicate to identify mise config files.
-- Used by the after/queries/ injection files to scope to *mise*.toml only.
local function register_mise_predicate()
  require("vim.treesitter.query").add_predicate("is-mise?", function(_, _, bufnr, _)
    local filepath = vim.api.nvim_buf_get_name(tonumber(bufnr) or 0)
    local filename = vim.fn.fnamemodify(filepath, ":t")
    return string.match(filename, ".*mise.*%.toml$") ~= nil
  end, { force = true, all = false })
end

register_mise_predicate()

-- Apply taplo schema for mise files
require("plugins.mise.settings").configure_taplo()

-- otter.nvim: LSP features for embedded languages in mise TOML
return {
  {
    "jmbuhr/otter.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      local function is_mise_file()
        local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
        return string.match(filename, ".*mise.*%.toml$") ~= nil
      end

      vim.api.nvim_create_autocmd({ "FileType" }, {
        pattern = { "toml" },
        group = vim.api.nvim_create_augroup("MiseOtter", {}),
        callback = function()
          if is_mise_file() then
            require("otter").activate()
          end
        end,
      })
    end,
  },
}
