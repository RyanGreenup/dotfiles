# Kubernetes YAML Support

LSP-powered hover, autocomplete, validation, and CRD schema detection for
Kubernetes manifests.

## Stack

```
yaml-companion.nvim  -- auto-detects k8s files, schema picker
  -> yamlls           -- LSP server (hover, completion, validation)
  -> SchemaStore.nvim  -- curated schema catalog (non-k8s YAML too)
  -> kubernetes keyword -- yannh/kubernetes-json-schema (core resources)
  -> datreeio/CRDs-catalog -- Flux, CNPG, Traefik, Kyverno schemas
```

## Files

| File           | Purpose                                                          |
| -------------- | ---------------------------------------------------------------- |
| `init.lua`     | Plugin specs + wiring. Calls `vim.lsp.config` / `vim.lsp.enable` |
| `schemas.lua`  | CRD definitions for the schema picker. Add new CRDs here         |
| `settings.lua` | Builds yamlls settings: SchemaStore + kubernetes + kustomization |

## Usage

- **Hover**: `K` on any field shows type + description
- **Autocomplete**: works automatically via nvim-cmp
- **Schema picker**: `<leader>ys` to select a schema manually (CRDs, etc.)
- **Modeline**: add as first line for CRDs not auto-detected:
  ```yaml
  # yaml-language-server: $schema=https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{group}/{kind}_{version}.json
  ```

## Adding CRDs

Add entries to `schemas.lua`:

```lua
{ name = "My CRD", uri = "https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/group.io/kind_v1.json" },
```

The datreeio/CRDs-catalog covers hundreds of popular CRDs. URL pattern:
`https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{group}/{kind}_{version}.json`
