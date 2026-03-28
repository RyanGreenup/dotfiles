# Mise Integration for Neovim

First-class support for editing mise configuration files and file tasks, based on the
[official mise cookbook](https://mise.jdx.dev/mise-cookbook/neovim.html).

## What it does

### Syntax highlighting in mise TOML

Inline `run` commands get proper syntax highlighting instead of rendering as plain strings.
The injection queries detect the language automatically:

- **Shebang detection**: a `run` block starting with `#!/usr/bin/env python` highlights as
  Python; `#!/bin/bash` highlights as bash; and so on for any language.
- **Default to bash**: single-line or multiline `run` values without a shebang highlight as
  bash, which is what mise uses by default.
- **Scoped to mise files**: a custom `#is-mise?` treesitter predicate ensures these
  injections only activate on files matching `*mise*.toml`, so normal TOML files are
  unaffected.

### LSP with schema validation

Taplo (the TOML language server) is configured with the
[official mise JSON schema](https://mise.jdx.dev/schema/mise.json). This provides:

- **Completions**: press `<C-Space>` in a mise TOML file and get completions for all valid
  keys: `[tools]`, `[env]`, `[tasks.*]`, `[settings]`, and every nested setting like
  `python.compile`, `node.flavor`, `task.timeout`, etc.
- **Hover documentation**: press `K` on any key to see what it does and its type.
- **Validation**: invalid keys, wrong types, and structural errors show as diagnostics
  inline.

The schema association matches `*mise*.toml` and `.mise/config.toml`, covering all standard
mise config file locations (`mise.toml`, `.mise.toml`, `mise.local.toml`,
`mise.<env>.toml`, `.mise/config.toml`, etc.).

### Embedded language LSP via otter.nvim

[otter.nvim](https://github.com/jmbuhr/otter.nvim) activates on mise TOML files and
provides LSP features _inside_ embedded code blocks. Completions, diagnostics,
and hover work inside `run = '''...'''` strings, not just in the TOML structure around them.

### File task comment highlighting

Mise [file tasks](https://mise.jdx.dev/tasks/file-tasks.html) use special comments for
configuration:

```bash
#!/usr/bin/env bash
#MISE description="Run the test suite"
#MISE depends=["build"]
#USAGE flag "-v" "Verbose output"

set -euo pipefail
echo "running tests"
```

The `#MISE` comments get TOML syntax highlighting and the `#USAGE` comments get KDL
highlighting, so the structured metadata stands out from the script body. This works in
bash, python, and any `#`-comment language.

## Files

| File                                  | Purpose                                                     |
| ------------------------------------- | ----------------------------------------------------------- |
| `lua/plugins/mise/init.lua`           | Plugin spec: `is-mise?` predicate, otter.nvim, taplo config |
| `lua/plugins/mise/settings.lua`       | Taplo schema association for mise files                     |
| `after/queries/toml/injections.scm`   | Bash/shebang injection in `run` strings                     |
| `after/queries/bash/injections.scm`   | TOML/KDL injection in `#MISE`/`#USAGE` comments             |
| `after/queries/python/injections.scm` | Same as bash, for Python file tasks                         |

The `after/queries/` files must remain at the project root; Neovim requires that
path for treesitter injection queries.

## Dependencies

- **taplo**: install via Mason (`:Mason` then search for `taplo`) or your system package
  manager. This is the TOML language server.
- **otter.nvim**: installed automatically by lazy.nvim from the plugin spec.
- **Treesitter parsers**: `toml` and `bash` are added to the auto-install list. They will
  install on next startup.

## References

- [mise configuration docs](https://mise.jdx.dev/configuration.html)
- [mise settings reference](https://mise.jdx.dev/configuration/settings.html)
- [mise file tasks](https://mise.jdx.dev/tasks/file-tasks.html)
- [mise JSON schema](https://mise.jdx.dev/schema/mise.json)
