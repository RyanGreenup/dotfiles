--- yamlls settings builder.
--- Merges SchemaStore.nvim catalog with Kubernetes schema associations.
--- Keeps yamlls built-in schemaStore disabled to avoid duplicates.

local M = {}

--- Build the yaml.schemas table by merging SchemaStore + Kubernetes mappings.
---@return table settings  yamlls-compatible settings table
function M.build()
  -- Merge SchemaStore catalog with our explicit schema-to-glob mappings.
  -- "kubernetes" is a special keyword in yamlls that:
  --   1. Downloads schemas from yannh/kubernetes-json-schema
  --   2. Suppresses "matches multiple schemas" errors in multi-doc files
  local schemas = vim.tbl_deep_extend("force", require("schemastore").yaml.schemas(), {
    kubernetes = {
      "*.yaml",
      "*.yml",
    },
    -- Kustomization files need their own schema (not kubernetes)
    ["https://json.schemastore.org/kustomization.json"] = {
      "kustomization.yaml",
      "kustomization.yml",
    },
  })

  return {
    redhat = { telemetry = { enabled = false } },
    yaml = {
      validate = true,
      hover = true,
      completion = true,
      format = { enable = true },

      -- Disable alphabetical key ordering enforcement.
      -- Kubernetes YAML has conventional field ordering (apiVersion, kind,
      -- metadata, spec) that matters more than alphabetical.
      keyOrdering = false,

      -- Disable yamlls built-in schemaStore. We use SchemaStore.nvim instead,
      -- which gives us control over which schemas load. Leaving both enabled
      -- causes duplicates and conflicts.
      schemaStore = {
        enable = false,
        url = "",
      },

      schemas = schemas,
    },
  }
end

return M
