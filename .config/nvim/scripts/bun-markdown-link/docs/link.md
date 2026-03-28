# cite link

Generate a markdown link to a file with an auto-extracted title.

## Usage

```bash
cite link <target> [--absolute] [--root <dir>]
```

## Output

Prints a markdown link to stdout:

```bash
cite link docs/guide.md
# [Guide title](./docs/guide.md)
```

The output is ready to paste into any markdown file.

## Title extraction

The title comes from the first source that matches:

1. Frontmatter title -- YAML (`title: value` between `---` delimiters) or TOML (`title = "value"` between `+++` delimiters)
2. First heading -- the first `#` heading in the document
3. Filename -- converted to sentence case (e.g., `getting-started.md` becomes "Getting started")

### Examples

YAML frontmatter:

```markdown
---
title: My Guide
---
```

TOML frontmatter:

```markdown
+++
title = "My Guide"
+++
```

First heading fallback:

```markdown
# My Guide
```

Filename fallback (no frontmatter or heading):

```
my-guide.md  ->  "My guide"
```

## Relative links (default)

The generated path is relative to the current working directory:

```bash
cite link ../other-project/docs/guide.md
# [Guide](../other-project/docs/guide.md)
```

## Absolute links (Starlight mode)

Use `--absolute` with `--root` to generate absolute URL paths, matching the convention used by [Astro Starlight](https://starlight.astro.build/) and similar file-based routers.

```bash
cite link src/content/docs/guides/setup.md --absolute --root src/content/docs
# [Getting Started](/guides/setup/)
```

In this mode:

- The path is computed relative to `--root` and prefixed with `/`
- The `.md` extension is stripped
- A trailing `/` is appended
- `index.md` files collapse to their parent directory (`reference/index.md` becomes `/reference/`)

### Examples

```bash
# Regular page
cite link src/content/docs/reference/faq.md --absolute --root src/content/docs
# [FAQ](/reference/faq/)

# Index page
cite link src/content/docs/guides/index.md --absolute --root src/content/docs
# [Guides](/guides/)
```

If `--root` is omitted, the current working directory is used as the content root.
