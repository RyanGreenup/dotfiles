# Getting started

Cite is a CLI tool that manages markdown links. It moves markdown files while keeping all internal and external links intact, and generates ready-to-paste markdown links with auto-extracted titles.

## Requirements

- [Bun](https://bun.sh/) runtime

## Installation

```bash
bun install
```

## Commands

### `cite move <source> <destination>`

Move a markdown file and automatically update all links that reference it.

```bash
bun run index.ts move docs/old-path.md docs/new-path.md
```

See [move](./move.md) for details.

### `cite link <target>`

Generate a markdown link to a file, with the title auto-extracted.

```bash
bun run index.ts link docs/guide.md
# [Guide title](./docs/guide.md)
```

See [link](./link.md) for details.
