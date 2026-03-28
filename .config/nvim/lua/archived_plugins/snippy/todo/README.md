# Archived Snippy Infrastructure

These files implement a complex contextual/modal snippet system for nvim-snippy.

## What each file did

- **snippy.lua** — Main snippy config with `My_snippy_state` global, `expand_options` for conditional snippet flags (`l`, `m`, `c`), and virtual marker settings.
- **snippy_symlink_toggle.lua** — Swapped symlinks between `tex_normal`/`tex_auto` and `markdown_normal`/`tex_auto` to toggle auto-trigger snippets on/off.
- **snippy_modes.lua** — Legacy state machine (`My_Snippy_env`) for toggling between normal/latex modes.
- **markdown_math.snippets** — Conditional math snippets using `m` flag (treesitter mathzone detection).
- **markdown_math_treesitter.snippets** — More conditional math snippets using `m` flag.
- **markdown_math_modal.snippets** — Snippets using `l` flag (latex mode toggle).
- **tex_auto** — Auto-trigger tex snippets, target of the symlink system.
- **tex_normal** — Normal tex snippets, target of the symlink system.
- **markdown_normal** — Had `l`-flag snippets and `!l` interpolation.

## The system

1. **Math zone detection** — `expand_options.m` called `tsutils_math.in_mathzone()` to conditionally expand snippets only inside math environments.
2. **Latex mode toggle** — `expand_options.l` checked `My_snippy_state.Mode.latex`, toggled via `<M-l>` or `<leader>tsl`.
3. **Symlink swapping** — `snippy_symlink_toggle.lua` toggled between normal/auto snippet files by swapping symlinks, enabling/disabling auto-trigger snippets.

## Recreating with LuaSnip

- **Conditions**: Use `condition` and `show_condition` on snippets (e.g., `condition = in_mathzone`).
- **Autosnippets**: LuaSnip has native `autosnippets` support with `condition` functions — no symlink hack needed.
- **Lua snippets**: Use `from_lua` loader with `LuaSnip/` directory for full programmatic control.
- **Math zone detection**: `lua/utils/tsutils_math.lua` is still available and works with any snippet engine.
