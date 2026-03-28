# cite move

Move a markdown file and update all links across the project.

## Usage

```bash
cite move <source> <destination>
```

## What it does

1. Moves the file from `source` to `destination`
2. Rewrites links inside the moved file so they still point to the correct targets from the new location
3. Scans every other markdown file in the project and updates any links that pointed to the old path

## Supported formats

Link rewriting works for all standard markdown link types:

- Inline links: `[text](path)`
- Images: `![alt](path)`
- Reference definitions: `[id]: path`

Both relative (`./sibling.md`, `../other/file.md`) and absolute (`/docs/file.md`) link styles are handled.

## Project root detection

Cite walks up from the destination directory looking for a `.git` directory. That directory becomes the project root. All markdown files under this root (`**/*.{md,mdx,mdoc,rmd}`) are scanned for links to update.

## Examples

Move a file into a subdirectory:

```bash
cite move guides/setup.md guides/getting-started/setup.md
```

Move a file and let cite infer the filename:

```bash
cite move old/notes.md archive/
# Moves to archive/notes.md
```
