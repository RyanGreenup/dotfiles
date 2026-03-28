--- Mise integration: filetype detection, treesitter injections, LSP, and otter.nvim

-- Custom treesitter predicate to identify mise config files
local function register_mise_predicate()
  require("vim.treesitter.query").add_predicate("is-mise?", function(_, _, bufnr, _)
    local filepath = vim.api.nvim_buf_get_name(tonumber(bufnr) or 0)
    local filename = vim.fn.fnamemodify(filepath, ":t")
    return string.match(filename, ".*mise.*%.toml$") ~= nil
  end, { force = true, all = false })
end

-- otter.nvim: LSP features for embedded languages in mise TOML
local otter = {
  "jmbuhr/otter.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
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
}

-- Register the is-mise? predicate at load time (uses built-in vim.treesitter API)
register_mise_predicate()

return {
  otter,
}
