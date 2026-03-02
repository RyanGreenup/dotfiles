#!/usr/bin/env python3
"""Rename chunk files using gpt-4.1-nano to generate descriptive names.

Reads each .md chunk under docs/swayfx/chunks/*/, sends the content to
gpt-4.1-nano, and renames the file based on the model's suggested slug.
The numeric prefix is preserved for ordering.

Requires: pip install openai
          OPENAI_API_KEY set in environment
"""

import re
from pathlib import Path

from openai import OpenAI

CHUNKS_DIR = Path(__file__).resolve().parent.parent / "docs" / "swayfx" / "chunks"
MODEL = "gpt-4.1-nano"

SYSTEM_PROMPT = """\
You name documentation chunk files. Given markdown content from a sway/swayfx \
man page chunk, respond with ONLY a short kebab-case filename slug (no extension, \
no number prefix). The slug should describe the specific topic of the chunk.

Rules:
- 2-5 words, kebab-case (e.g. "input-pointer-config", "ipc-get-tree-reply")
- Be specific to the content, not generic (avoid "overview", "introduction", "misc")
- If it covers a specific command, option, or section, name it after that
- Output ONLY the slug, nothing else\
"""


def suggest_name(client: OpenAI, content: str) -> str:
    """Ask gpt-4.1-nano for a filename slug based on chunk content."""
    # Truncate to avoid wasting tokens on large chunks
    trimmed = content[:1500]
    resp = client.chat.completions.create(
        model=MODEL,
        messages=[
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": trimmed},
        ],
        max_tokens=30,
        temperature=0,
    )
    raw = resp.choices[0].message.content or ""
    slug = raw.strip().strip("`\"'")
    # Sanitize to strict kebab-case
    slug = re.sub(r"[^a-z0-9-]", "", slug.lower()).strip("-")
    return slug or "chunk"


def rename_chunks_in(directory: Path, client: OpenAI) -> int:
    """Rename all .md files in a single chunk directory. Returns count."""
    files = sorted(directory.glob("*.md"))
    seen_slugs: dict[str, int] = {}
    count = 0

    for f in files:
        # Extract numeric prefix
        match = re.match(r"^(\d+)", f.name)
        prefix = match.group(1) if match else f"{count:03d}"

        content = f.read_text()
        slug = suggest_name(client, content)

        # Deduplicate slugs within a directory
        if slug in seen_slugs:
            seen_slugs[slug] += 1
            slug = f"{slug}-{seen_slugs[slug]}"
        else:
            seen_slugs[slug] = 0

        new_name = f"{prefix}-{slug}.md"
        new_path = f.parent / new_name

        if new_path != f:
            f.rename(new_path)

        count += 1

    return count


def main() -> None:
    if not CHUNKS_DIR.exists():
        print(f"Chunks directory not found: {CHUNKS_DIR}")
        print("Run `just chunk-markdown` first.")
        return

    client = OpenAI()
    dirs = sorted(d for d in CHUNKS_DIR.iterdir() if d.is_dir())

    total = 0
    for d in dirs:
        n = rename_chunks_in(d, client)
        total += n
        print(f"  {d.name + '/':30s} {n} files renamed")

    print(f"\n{total} files renamed under {CHUNKS_DIR}")


if __name__ == "__main__":
    main()
