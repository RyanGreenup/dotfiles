# Neovim Config

Lua-based Neovim configuration managed via a bare git dotfiles repo.

## Configuration

All tuneable settings live in [`lua/config.lua`](lua/config.lua). This is the single source of truth for vim options, theme choices, and plugin preferences. `lua/settings.lua` reads from it and applies the values — edit `config.lua`, restart Neovim, and the changes take effect.

## Structure

```
init.lua                  Entry point
lua/
  config.lua              User-tuneable settings
  settings.lua            Applies settings from config.lua
  keymaps.lua             All keybindings (plugin and built-in)
  config/                 Plugin configuration modules
    blink-cmp.lua         blink.cmp completion setup
    luasnip.lua           LuaSnip snippet engine
    lsp.lua               LSP client configuration
    lsp_server_list.lua   LSP servers for mason to install
    which-key.lua         Keybinding hints and leader menus
    org-mode.lua          Orgmode setup
    themes.lua            Colorscheme configuration
    ...
  plugins/                Lazy.nvim plugin specs
    lsp.lua               LSP, blink.cmp, treesitter, mason
    ui.lua                Lualine, neo-tree, flash, focus, etc.
    telescope.lua         Telescope and extensions
    formatting.lua        Conform.nvim (stylua, ruff, oxfmt, etc.)
    notetaking.lua        Orgmode, markdown preview, femaco
    avante.lua            LLM integration
    dap.lua               Debug adapter protocol
    ...
  utils/                  Utility modules (slime, math zone, etc.)
snippets/                 Snipmate-format snippets
LuaSnip/                  Native Lua snippets (markdown, dokuwiki)
Dockerfile                Container for testing dependencies
justfile                  Task runner (podman test, format, etc.)
```

## Setup

This should work out of the box — start Neovim and it will self-configure. Mason auto-installs LSP servers on first launch.

### R Language Server

R requires manual setup:

```r
install.packages("stringi")
install.packages("tidyverse")  # optional, good checkhealth
```

Then in Neovim: `:LspInstall r_language_server` (~10 min on slow machines).

## Dependencies

The [`Dockerfile`](Dockerfile) serves as the canonical list of system dependencies. Key requirements:

| Dependency | Purpose |
|---|---|
| `neovim` >= 0.11 | Editor |
| `git` | Plugin management (lazy.nvim) |
| `uv` | Python LSP servers (basedpyright, ruff) via `uvx` |
| `tree-sitter-cli` | Treesitter parser compilation |
| `cmake`, `gcc`/`clang` | Native telescope-fzf, treesitter parsers |
| `npm` | Tree-sitter CLI, LSP servers via mason |
| `luajit`, `libluajit-5.1-dev` | LuaSnip jsregexp build |
| `unzip` | Mason LSP server extraction |

Python LSP servers (basedpyright, ruff) are managed by `uv` rather than Mason's venvs — see [`lua/config/lsp.lua`](lua/config/lsp.lua). On first use, `uvx` auto-downloads and caches the tools.

Install on Arch Linux:

```sh
sudo pacman -S neovim git uv tree-sitter-cli cmake gcc npm python luajit unzip
```

Install on Ubuntu/Debian (see Dockerfile for exact versions):

```sh
apt install git cmake gcc clang npm unzip luajit libluajit-5.1-dev
# Neovim: download from https://github.com/neovim/neovim/releases
# uv: curl -LsSf https://astral.sh/uv/install.sh | sh
```

## Testing with Podman

The [`justfile`](justfile) provides container-based testing:

```sh
# Test local (working tree) config in a container
just podman-run

# Test committed config from the dotfiles bare repo
just podman-run-committed

# Clean build (no layer cache)
NO_CACHE=1 just podman-run
```

The container skips mason LSP auto-install (`NVIM_SKIP_MASON=1`) since mason downloads platform-specific binaries that may not work in the container.

## Formatting

```sh
just fmt  # Runs stylua on all Lua files
```

Formatting config per filetype is defined in [`lua/plugins/formatting.lua`](lua/plugins/formatting.lua) (conform.nvim).

## Snippets

Uses [LuaSnip](https://github.com/L3MON4D3/LuaSnip) with two snippet sources:

- **`snippets/`** — Snipmate-format snippets (python, typescript, yaml, markdown, dokuwiki)
- **`LuaSnip/`** — Native Lua snippets (markdown autosnippets, dokuwiki)
- **[vim-snippets](https://github.com/honza/vim-snippets)** — Community snippets (bundled as dependency)

Browse available snippets with `<leader>sn` (Telescope LuaSnip picker).

### Archived snippet infrastructure

Complex contextual/modal snippet systems (math zone detection, latex mode toggling, symlink swapping) are archived in `lua/archived_plugins/snippy/todo/` with a README documenting how to recreate them with LuaSnip conditions.

## SQL Language Server (sqlls)

Requires a `.sqllsrc.json` in your project root:

```json
{
  "name": "my-project",
  "adapter": "sqlite3",
  "filename": "./database.sqlite"
}
```

Tables must have aliases for column completions:

```sql
SELECT i.sepal_width FROM iris i;  -- works
SELECT sepal_width FROM iris;      -- no completions
```

Adapters: `sqlite3`, `mysql`, `postgres`, `bigquery`

**Limitation:** sqlls does NOT support SSL for PostgreSQL. For managed databases requiring SSL, use an SSH tunnel or local proxy.

## Updating

```sh
# Manual
nvim --headless "+Lazy! sync" +qa

# Cron (daily at 1am)
# crontab -e
0 1 * * * nvim --headless "+Lazy! sync" +qa
```

## Julia

See [Julia Sys Images](./julia_images.md).
