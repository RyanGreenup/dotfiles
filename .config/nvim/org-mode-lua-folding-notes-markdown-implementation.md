# Orgmode-Style Fold Cycling for Markdown

Orgmode-style `<TAB>`/`<S-TAB>` fold cycling for markdown files, ported from
[nvim-orgmode](https://github.com/nvim-orgmode/orgmode)'s `OrgMappings:cycle()` and
`OrgMappings:global_cycle()` (in `lua/orgmode/org/mappings.lua`).

## File layout

```
~/.config/nvim/markdown-editing/
  lua/md_fold/
    init.lua          setup(), FileType autocmd, keybinding wiring
    fold_cycle.lua    cycle() and global_cycle()
    treesitter.lua    markdown treesitter helpers (section navigation)
    foldtext.lua      custom foldtext with link concealment
```

Loaded via rtp prepend in `~/.config/nvim/init.lua`:

```lua
vim.opt.rtp:prepend(vim.fn.stdpath('config') .. '/markdown-editing')
require('md_fold').setup()
```

## Configuration

`setup()` accepts an optional table:

```lua
require('md_fold').setup({
  startup_folded = 'content',  -- 'overview' | 'content' | 'showeverything'
})
```

| Value              | Behavior                              | `foldlevel` |
|--------------------|---------------------------------------|-------------|
| `'overview'`       | All headings folded                   | 0           |
| `'content'`        | Top-level headings visible (default)  | 1           |
| `'showeverything'` | Nothing folded                        | 99          |

## Keybindings

Buffer-local, active in `markdown` and `rmd` filetypes.

| Key       | Action         | Function                      |
|-----------|----------------|-------------------------------|
| `<TAB>`   | Local cycle    | `md_fold.fold_cycle.cycle()`  |
| `<S-TAB>` | Global cycle   | `md_fold.fold_cycle.global_cycle()` |

## How local cycling works (`<TAB>`)

Three-state cycle on the heading under the cursor:

```
Folded  -->  Children headings visible  -->  Fully expanded  -->  Folded
 (zc)              (zo / zc children)             (zczO)           (zc)
```

Decision logic (mirrors `OrgMappings:cycle()`):

1. If folding is disabled, re-enable it and recompute folds (`zx`).
2. If `foldlevel(line) == 0`, echo "No fold" — cursor is not on a foldable line.
3. If the fold is closed, open one level (`zo`).
4. If the fold is open, inspect the treesitter `section` node:
   - **No children, one-liner** — no-op (nothing to fold).
   - **No children, has body** — close (`zc`).
   - **Has children** — iterate child sections:
     - If any open+expandable child exists, close it. After the loop, close the
       parent too (`zc`). This produces the "children headings visible" state.
     - If all children are already closed, close then recursively open (`zczO`)
       to reach fully expanded.

## How global cycling works (`<S-TAB>`)

Cycles the entire buffer through three states, tracked in `vim.w.md_fold_global_state`:

```
Overview  -->  Contents  -->  Show All  -->  Overview
 (zMzX)      (foldlevel=1)     (zR)          (zMzX)
```

Each transition echoes the new state name.

## Treesitter structure

The markdown treesitter parser produces a tree where sections nest:

```
document
  section              (# Top heading)
    atx_heading
    paragraph
    section            (## Sub heading)
      atx_heading
      paragraph
      section          (### Sub-sub heading)
        ...
```

The `treesitter.lua` module navigates this tree:

- `get_section_at_line(bufnr, line)` — walks up from the node at cursor to the
  nearest `section` ancestor.
- `get_child_sections(section)` — direct `section`-typed children.
- `get_heading_line(section)` — finds the `atx_heading` child, returns its
  1-indexed line.
- `is_one_line(section)` — true if the section spans only its heading line.
- `has_child_sections(section)` — boolean shortcut.

## Foldtext

Custom fold display (`foldtext.lua`):

- Conceals markdown links `[text](url)` to just `text` when `conceallevel > 0`.
- Appends a line count: `## Heading ... (12 lines)`.

## Origin

The cycling logic is a direct port of nvim-orgmode's fold cycling. The key
source is `lua/orgmode/org/mappings.lua`, specifically:

- `OrgMappings:cycle()` (lines 82-145) — local fold toggle
- `OrgMappings:global_cycle()` (lines 147-162) — whole-buffer toggle

Adapted for markdown by replacing orgmode's headline API with treesitter
`section` node traversal.
