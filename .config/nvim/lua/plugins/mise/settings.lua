--- Taplo (TOML LSP) schema association for mise config files.
--- Provides completions, hover, and validation for all mise settings.

local M = {}

--- Apply mise schema to taplo via vim.lsp.config.
function M.configure_taplo()
  vim.lsp.config("taplo", {
    settings = {
      evenBetterToml = {
        schema = {
          enabled = true,
          repositoryEnabled = true,
          associations = {
            [".*mise.*\\.toml$"] = "https://mise.jdx.dev/schema/mise.json",
            [".*\\.mise/config\\.toml$"] = "https://mise.jdx.dev/schema/mise.json",
          },
        },
      },
    },
  })
end

return M
