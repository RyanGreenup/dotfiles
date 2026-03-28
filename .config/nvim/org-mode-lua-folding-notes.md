# nvim-orgmode Folding Implementation Notes

## Overview

Folding in nvim-orgmode has 3 layers: fold computation (where folds are),
fold text (what closed folds look like), and fold cycling (user interaction).

## 1. Fold Computation — Treesitter foldexpr

Set in `ftplugin/org.lua`:

```lua
vim.opt_local.foldmethod = 'expr'
vim.opt_local.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
```

This uses **Neovim's built-in** `vim.treesitter.foldexpr()` — not a custom
one. Neovim walks the parsed tree and assigns fold levels based on `@fold`
captures in the treesitter query files.

### folds.scm (`queries/org/folds.scm`)

```query
([
  (section)
  (table)
  (drawer)
  (property_drawer)
  (block)
  ] @fold (#org-set-fold-offset! @fold))
```

The `@fold` capture tells Neovim which treesitter nodes are foldable. In org,
`(section)` nodes nest under headings, so each heading level maps naturally to
a fold level. Tables, drawers, property drawers, and blocks are also foldable.

The `#org-set-fold-offset!` predicate is a custom directive (registered by the
plugin) that adjusts fold offsets for org-specific behavior.

### How treesitter foldexpr works (from nvim-treesitter docs)

- Query files live at `queries/<language>/folds.scm`
- Valid captures: `@fold` applied to nodes with clear start/end delimiters
- Common foldable nodes: function definitions, headings (`@markup.heading.x`),
  blocks, classes, consecutive imports, comments
- Neovim evaluates `foldexpr` per-line, walking the tree to determine the fold
  level from the nesting depth of `@fold`-captured nodes

## 2. Startup Fold Level

`lua/orgmode/config/init.lua` — `Config:setup_foldlevel()`:

| `org_startup_folded` | `foldlevel` | Effect                               |
|----------------------|-------------|--------------------------------------|
| `'overview'` (default) | 0         | All headings collapsed               |
| `'content'`          | 1           | Level-1 headings open, rest collapsed|
| `'showeverything'`   | 99          | Everything open                      |
| `'inherit'`          | —           | Uses whatever Neovim already has     |

## 3. Fold Text — Two Modes

Controlled by `ui.folds.colored` (default: `true`).

### Colored mode (`lua/orgmode/colors/highlighter/foldtext.lua`)

Sets `foldtext = ''` (empty string), telling Neovim to render the first line
as-is. Then `OrgFoldtext:on_line()` uses the highlighter's decorator callback
to place a virtual text overlay with `org_ellipsis` (default `"..."`) at the
end of the line. The ellipsis is colored to match the treesitter highlight
group of that heading level (e.g., `@markup.heading.1.org`).

It caches fold open/closed state per buffer/line to avoid redundant treesitter
queries on each redraw.

### Plain mode (`lua/orgmode/org/indent.lua` — `foldtext()`)

Used when `ui.folds.colored = false`. A custom `foldtext()` function that:

1. Gets the first line of the fold
2. If `hide_leading_stars` is on, replaces leading `*` chars with spaces
   (keeping one visible)
3. If `conceallevel > 0`, resolves org links `[[url][text]]` to just the
   visible text
4. Appends `org_ellipsis`

## 4. Fold Cycling — `<TAB>` and `<S-TAB>`

### Local cycle (`<TAB>`) — `OrgMappings:cycle()`

`lua/orgmode/org/mappings.lua:82-145`

Cycling on a heading goes through states:

1. **Folded** → open one level (`zo`)
2. **Open with closed children** → recursively open all (`zczO`)
3. **Fully open** → close (`zc`)

It checks whether children have their own sub-headings/content and decides
whether there's another expansion level or it should close. Drawers
(`:PROPERTIES:` etc.) also toggle with `za`.

If folding is disabled (`foldenable = false`), pressing `<TAB>` re-enables it
and recomputes folds with `zx`.

### Global cycle (`<S-TAB>`) — `OrgMappings:global_cycle()`

`lua/orgmode/org/mappings.lua:147-162`

Cycles the entire buffer through three states:

1. **Overview** — all closed (`zMzX`, foldlevel=0)
2. **Contents** — level-1 open (foldlevel=1, `zx`)
3. **Show All** — everything open (`zR`)

## 5. Supporting Details

- `fillchars` is set to `fold: ` (space) to avoid ugly fill characters
- `org_cycle_separator_lines` (default: 2) controls how many blank lines are
  needed at the end of a section to show a separator between folded headings
- The format expression (`lua/orgmode/org/format.lua`) is fold-aware — it
  detects `foldclosed()` to avoid infinite loops when formatting ranges that
  span closed folds
- The indent module (`lua/orgmode/org/indent.lua`) has a separate treesitter
  query (`org_indent`) for indentation, distinct from the fold query

## Key Files

| File | Role |
|------|------|
| `ftplugin/org.lua` | Sets foldmethod, foldexpr, foldtext, calls setup_foldlevel |
| `queries/org/folds.scm` | Treesitter fold query — defines which nodes are foldable |
| `lua/orgmode/config/init.lua` | `setup_foldlevel()` — startup fold state |
| `lua/orgmode/config/defaults.lua` | Default values for fold-related options |
| `lua/orgmode/org/indent.lua` | `foldtext()` for plain (non-colored) mode |
| `lua/orgmode/colors/highlighter/foldtext.lua` | Colored fold text with treesitter-aware highlighting |
| `lua/orgmode/org/mappings.lua` | `cycle()` and `global_cycle()` fold interaction |
| `lua/orgmode/org/format.lua` | Fold-aware `formatexpr` |
