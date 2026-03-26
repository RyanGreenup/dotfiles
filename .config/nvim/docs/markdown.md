# Orgmark: Org-Mode-Style Markdown Editing

Orgmark is a self-contained Lua module at `lua/orgmark/` that brings Emacs
org-mode behavior to Markdown (and MDX) files. It replaces the old `md_fold`
and `markdown_editor.nvim` plugins.

Activate it with a single call in `init.lua`:

```lua
require('orgmark').setup()
-- or with overrides:
require('orgmark').setup({
  folding = { startup_folded = 'overview' },
})
```

## Folding

Treesitter-based folding with org-mode-style cycling.

| Key     | Action                                                   |
|---------|----------------------------------------------------------|
| `TAB`   | Local fold cycle: Folded -> Children -> Subtree -> Folded |
| `S-TAB` | Global fold cycle: Overview -> Contents -> Show All       |

**Local cycle (`TAB`)** operates on the heading under the cursor:

1. **Folded** — heading is collapsed. `TAB` opens one level ("Children").
2. **Children visible** — direct children are visible but their subtrees are
   closed. `TAB` recursively opens everything ("Subtree").
3. **Fully expanded** — everything is open. `TAB` closes the fold ("Folded").

If folding is disabled (`foldenable=false`), pressing `TAB` re-enables it.

**Global cycle (`S-TAB`)** rotates the entire buffer through three states:

1. **OVERVIEW** — all headings collapsed (`foldlevel=0`).
2. **CONTENTS** — level-1 headings open, everything else collapsed (`foldlevel=1`).
3. **SHOW ALL** — everything open.

### Fold text

Closed folds display the heading text with markdown links concealed, followed
by an ellipsis and a line count:

```
## Getting Started … (42 lines)
```

### Configuration

```lua
require('orgmark').setup({
  folding = {
    startup_folded = 'content',    -- 'overview' | 'content' | 'showeverything'
    ellipsis = '…',                -- character appended to fold text
    show_line_count = true,        -- show "(N lines)" in fold text
  },
})
```

## Heading Management

All heading operations use treesitter to detect heading boundaries and levels.

| Key              | Mode | Action                        |
|------------------|------|-------------------------------|
| `M-Left`         | n    | Promote heading (remove `#`)  |
| `M-Right`        | n    | Demote heading (add `#`)      |
| `M-S-Left`       | n    | Promote subtree (all children)|
| `M-S-Right`      | n    | Demote subtree (all children) |
| `C-CR`           | n, i | Insert child heading          |
| `M-CR`           | n, i | Insert sibling heading        |
| `M-Up`           | n    | Move subtree up               |
| `M-Down`         | n    | Move subtree down             |
| `M-h`            | n    | Smart: promote heading *or* outdent list item |
| `M-l`            | n    | Smart: demote heading *or* indent list item   |

### Promote / Demote

- **Single heading** (`M-Left`/`M-Right`): changes only the heading under the
  cursor. Level is clamped to 1-6.
- **Subtree** (`M-S-Left`/`M-S-Right`): changes the heading *and* every child
  heading within its section. Edits are applied in reverse line order so line
  numbers stay stable.

### Insert

- **Child heading** (`C-CR`): inserts a heading one level deeper than the
  current heading, directly below the cursor. Enters insert mode.
- **Sibling heading** (`M-CR`): inserts a heading at the same level, at the
  end of the current section. Enters insert mode.

If the cursor is not on a heading, both commands walk backwards to find the
nearest heading for context. A blank line is inserted before the new heading
when the preceding line is not empty.

### Move Subtree

`M-Up`/`M-Down` swaps the current subtree with its previous/next sibling
section. The cursor follows the moved heading.

## Navigation

| Key        | Mode | Action                     |
|------------|------|----------------------------|
| `C-c C-n`  | n    | Next heading (any level)   |
| `C-c C-p`  | n    | Previous heading           |
| `C-c C-f`  | n    | Next sibling heading       |
| `C-c C-b`  | n    | Previous sibling heading   |
| `C-c C-u`  | n    | Parent heading             |

All navigation commands center the view (`zz`) after jumping.

- **Sibling** navigation stays within the same parent section and matches the
  current heading level.
- **Parent** navigation walks up the treesitter tree to find the enclosing
  section's heading.

## TODO States

Headings can carry a TODO keyword between the `#` markers and the title text:

```markdown
## TODO Fix the parser
## DOING Write tests
## DONE Ship it
```

| Key       | Mode | Action                |
|-----------|------|-----------------------|
| `S-Right` | n    | Cycle TODO forward    |
| `S-Left`  | n    | Cycle TODO backward   |

The cycle sequence is: *(none)* -> `TODO` -> `DOING` -> `DONE` -> *(none)*.

The keyword list is configurable via `require('orgmark.todo').states`.

## Checkboxes

Markdown checkboxes use `- [ ]`, `- [x]`, and `- [-]` syntax with any list
marker (`-`, `*`, `+`).

| Key       | Mode | Action           |
|-----------|------|------------------|
| `C-c C-c` | n    | Toggle checkbox  |

Toggling cycles `[ ]` -> `[x]` and `[x]`/`[-]` -> `[ ]`.

### Statistics Cookies

If a parent list item or heading contains a fraction cookie `[0/3]` or a
percent cookie `[0%]`, it is automatically updated when a child checkbox is
toggled.

```markdown
## Tasks [1/3]
- [x] First thing
- [ ] Second thing
- [ ] Third thing
```

Toggling "Second thing" updates the heading to `[2/3]`. Cookies are only
updated if they already exist — orgmark never auto-inserts them.

## Priority

Headings can carry a priority marker: `[#A]`, `[#B]`, or `[#C]`.

```markdown
## TODO [#A] Critical bug
## [#C] Low priority note
```

| Key     | Mode | Action                                      |
|---------|------|---------------------------------------------|
| `S-Up`  | n    | Cycle priority (or shift date — see below)  |
| `S-Down`| n    | Cycle priority (or shift date — see below)  |

Priority cycle: *(none)* -> `[#A]` -> `[#B]` -> `[#C]` -> *(none)*.

The priority marker is placed after the TODO keyword when one exists, or
directly after the `#` markers otherwise.

**Context-aware behavior:** `S-Up`/`S-Down` check if the current line
contains a date (`YYYY-MM-DD`). If so, they shift the date instead. If not,
they cycle the priority.

## Smart Lists

| Key            | Mode | Action                      |
|----------------|------|-----------------------------|
| `CR` (Enter)   | i    | Smart list continuation     |
| `M-h`          | n    | Outdent list item           |
| `M-l`          | n    | Indent list item            |

### Smart Return

Pressing Enter in insert mode on a list item:

1. **Item has content** — creates a new item at the same indent level with the
   same marker type. Ordered lists auto-increment the number. Checkbox lists
   start with `[ ]`.

   ```
   - Some text|        ->    - Some text
                              - |
   2. Second item|     ->    2. Second item
                              3. |
   - [x] Done|         ->    - [x] Done
                              - [ ] |
   ```

2. **Item is empty** (just the marker, no text) — deletes the marker and
   leaves a blank line. This exits the list naturally.

   ```
   - |                 ->    |
   ```

3. **Not on a list item** — performs a normal Enter.

Text after the cursor is carried to the new line (mid-line splits work).

### Indentation

`M-h`/`M-l` on a list item adds or removes 2 spaces of indentation (the
indent width is configurable via `require('orgmark.lists.indent').indent_width`).
On a heading line, these keys promote/demote the heading instead.

Ordered lists are automatically renumbered after indent/outdent operations.

### Auto-Renumbering

When an ordered list item is added, removed, or indented, orgmark finds the
contiguous block of ordered items at the same indent level and renumbers them
sequentially starting from 1.

## Timestamps

| Key     | Mode | Action                               |
|---------|------|--------------------------------------|
| `C-c .` | n    | Insert date: `<2026-03-26>`          |
| `1C-c .`| n    | Insert date+time: `<2026-03-26 14:30>` |
| `C-c !` | n    | Insert timestamp (always with time)  |

Dates use org-mode-style angle brackets. `insert_date_plain()` is also
available programmatically for bracket-free dates.

### Date Shifting

`S-Up`/`S-Down` on a line containing a `YYYY-MM-DD` date shift the component
under the cursor:

| Cursor on | S-Up             | S-Down           |
|-----------|------------------|------------------|
| Year      | +1 year          | -1 year          |
| Month     | +1 month         | -1 month         |
| Day       | +1 day           | -1 day           |
| Hour      | +1 hour          | -1 hour          |
| Minute    | +5 minutes       | -5 minutes       |

All arithmetic uses `os.time`/`os.date` so month lengths, leap years, and
overflow are handled correctly.

## Narrow / Widen

| Key       | Mode | Action              |
|-----------|------|---------------------|
| `C-x ns`  | n    | Narrow to subtree   |
| `C-x nw`  | n    | Widen (restore)     |

**Narrow** folds everything outside the current section, giving you a focused
view of just that subtree. The echo area shows which heading you narrowed to.

**Widen** opens all folds and recomputes the treesitter fold structure.

## Sparse Trees

| Key       | Mode | Action                      |
|-----------|------|-----------------------------|
| `C-c /`   | n    | Search headings by pattern  |
| `C-c /t`  | n    | Show TODO/DOING headings    |
| `C-c /d`  | n    | Show DONE headings          |

Sparse trees close all folds, then selectively reveal only matching headings
and their parent hierarchy. The cursor jumps to the first match.

Search is case-insensitive and uses plain text matching (not regex).

## Links

| Key       | Mode | Action                        |
|-----------|------|-------------------------------|
| `C-c C-l` | n    | Insert or edit a markdown link |
| `C-c C-l` | v    | Wrap selection as link text    |

- If the cursor is on an existing `[text](url)`, prompts to edit both parts.
- In visual mode, uses the selection as the link text and prompts for URL.
- Otherwise, prompts for both link text and URL.

## Rendering

Orgmark enables `render-markdown.nvim` for visual rendering in normal mode.
This is configured in `lua/plugins/notetaking.lua`.

| Element    | Rendering                                |
|------------|------------------------------------------|
| Headings   | `◉ ○ ✸ ✿ ◆ ◇` icons with background highlighting |
| Bullets    | `● ○ ◆ ◇` icons cycling by nesting level |
| Checkboxes | `☐` unchecked, `☑` checked, `◐` in-progress |
| Code blocks| Full-width background with thin borders  |

Concealment is set to `conceallevel=2` and `concealcursor=nc`, so links
display as their text content in normal and command mode but show the full
`[text](url)` syntax in insert mode.

## Module Architecture

```
lua/orgmark/
├── init.lua              Entry point: setup() creates FileType autocmd
├── config.lua            Defaults + deep-merge
├── treesitter.lua        12 treesitter query utilities
├── keymaps.lua           All buffer-local keybindings
├── links.lua             Link insertion/editing
├── narrow.lua            Narrow to subtree / widen
├── sparse.lua            Sparse tree views
├── folding/
│   ├── init.lua          foldmethod, foldexpr, foldtext, foldlevel
│   ├── cycle.lua         TAB / S-TAB cycling logic
│   └── text.lua          Custom foldtext with link concealment
├── headings/
│   ├── init.lua          Re-exports all heading functions
│   ├── promote.lua       Promote/demote (single + subtree)
│   ├── insert.lua        Insert sibling/child
│   ├── move.lua          Move subtree up/down
│   └── navigate.lua      Next/prev/sibling/parent
├── todo/
│   ├── init.lua          TODO state cycling + parse_heading()
│   ├── checkbox.lua      Toggle + statistics cookies
│   └── priority.lua      [#A]/[#B]/[#C] cycling
├── lists/
│   ├── init.lua          Smart return (list continuation)
│   ├── indent.lua        Indent / outdent
│   └── renumber.lua      Auto-renumber ordered lists
└── timestamps/
    ├── init.lua          Date/timestamp insertion
    └── shift.lua         Component-aware date shifting
```

All treesitter operations go through `orgmark.treesitter`. Line numbers are
1-indexed throughout. Each submodule is independently `require`-able.

## Filetypes

Orgmark activates for `markdown` and `mdx` files by default. Override with:

```lua
require('orgmark').setup({ filetypes = { 'markdown' } })
```

## See Also

- `docs/keymaps.md` — global keybinding reference
- `docs/slime.md` — REPL / code cell execution
- `org-mode-lua-folding-notes.md` — design notes from nvim-orgmode's folding
