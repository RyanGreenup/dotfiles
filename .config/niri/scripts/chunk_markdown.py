#!/usr/bin/env python3
"""Chunk markdown docs into smaller files using chonkie.

Reads each .md file from docs/ and splits it into chunks using chonkie's
MarkdownChef + RecursiveChunker + TableChunker pipeline. MarkdownChef
parses the document into text sections, tables, and code blocks. Text
sections use the recursive markdown recipe (headers -> paragraphs ->
lines -> sentences -> words). Tables are chunked row-by-row with headers
preserved in every chunk. Code blocks are kept intact.

Each doc gets its own subdirectory under docs/chunks/ with numbered
chunk files.

Requires: pip install chonkie huggingface_hub
"""

import re
import shutil
from dataclasses import dataclass, field
from functools import lru_cache
from pathlib import Path

from chonkie import MarkdownChef, RecursiveChunker, TableChunker

DOCS_DIR = Path(__file__).resolve().parent.parent / "docs"
CHUNKS_DIR = DOCS_DIR / "chunks"
CHUNK_SIZE = 512
CHUNK_OVERLAP = 64

_CHEF = MarkdownChef()


@dataclass
class Chunk:
    """A text chunk with position and token count."""

    text: str
    start_index: int
    end_index: int
    token_count: int
    metadata: dict[str, str] = field(default_factory=dict)


@lru_cache(maxsize=4)
def _text_chunker(chunk_size: int) -> RecursiveChunker:
    return RecursiveChunker.from_recipe("markdown", lang="en", chunk_size=chunk_size)


@lru_cache(maxsize=4)
def _table_chunker(chunk_size: int) -> TableChunker:
    return TableChunker(chunk_size=chunk_size)


def chunk_markdown(
    text: str,
    *,
    chunk_size: int = CHUNK_SIZE,
    overlap: int = CHUNK_OVERLAP,
) -> list[Chunk]:
    """Split markdown into chunks with table-header preservation.

    Tables are chunked row-by-row (preserving the header in every chunk)
    and code blocks are kept intact. Plain text sections use the recursive
    markdown strategy (headers -> paragraphs -> lines -> sentences -> words).
    """
    doc = _CHEF.parse(text)
    result: list[Chunk] = []

    # Plain text sections — recursive markdown splitting
    text_chunker = _text_chunker(chunk_size)
    for section in doc.chunks:
        section_end = section.start_index + len(section.text)
        for c in text_chunker.chunk(section.text):
            abs_start = section.start_index + c.start_index
            abs_end = section.start_index + c.end_index
            if overlap > 0:
                abs_start = max(section.start_index, abs_start - overlap)
                abs_end = min(section_end, abs_end + overlap)
            result.append(
                Chunk(
                    text=text[abs_start:abs_end],
                    start_index=abs_start,
                    end_index=abs_end,
                    token_count=c.token_count,
                )
            )

    # Tables — row-aware splitting that repeats the header in every chunk
    # TODO: MarkdownChef quite often pushes the header row down to row 1
    # instead of row 0; we'll handle that in a future pass.
    table_chunker = _table_chunker(chunk_size)
    for table in doc.tables:
        for c in table_chunker.chunk(table.content):
            result.append(
                Chunk(
                    text=c.text,
                    start_index=table.start_index + c.start_index,
                    end_index=table.start_index + c.end_index,
                    token_count=c.token_count,
                )
            )

    # Code blocks — never split
    for code in doc.code:
        result.append(
            Chunk(
                text=code.content,
                start_index=code.start_index,
                end_index=code.end_index,
                token_count=0,
            )
        )

    result.sort(key=lambda c: c.start_index)
    return result


def slug_from_heading(text: str) -> str:
    """Extract a short slug from the first markdown heading in the chunk."""
    match = re.search(r"^#+ +(.+)", text, re.MULTILINE)
    if not match:
        return ""
    heading = match.group(1).strip().lower()
    heading = re.sub(r"[^a-z0-9]+", "-", heading).strip("-")
    return heading


def chunk_file(
    md_path: Path,
    *,
    chunk_size: int = CHUNK_SIZE,
    overlap: int = CHUNK_OVERLAP,
    chunks_dir: Path = CHUNKS_DIR,
) -> int:
    """Chunk a single markdown file into a subdirectory. Returns chunk count."""
    stem = md_path.name.removesuffix(".md")  # e.g. "sway.1"
    out_dir = chunks_dir / stem
    out_dir.mkdir(parents=True, exist_ok=True)

    text = md_path.read_text()
    chunks = chunk_markdown(text, chunk_size=chunk_size, overlap=overlap)

    for i, chunk in enumerate(chunks):
        slug = slug_from_heading(chunk.text)
        suffix = f"-{slug}" if slug else ""
        filename = f"{i:03d}{suffix}.md"
        (out_dir / filename).write_text(chunk.text)

    return len(chunks)


def main(
    chunk_size: int = CHUNK_SIZE,
    overlap: int = CHUNK_OVERLAP,
    docs_dir: Path | None = None,
) -> None:
    docs_dir = docs_dir or DOCS_DIR
    chunks_dir = docs_dir / "chunks"

    md_files = sorted(docs_dir.glob("*.md"))
    if not md_files:
        print("No .md files found in", docs_dir)
        return

    # Clean previous chunks
    if chunks_dir.exists():
        shutil.rmtree(chunks_dir)

    total = 0
    for md_path in md_files:
        n = chunk_file(md_path, chunk_size=chunk_size, overlap=overlap,
                       chunks_dir=chunks_dir)
        total += n
        print(f"  {md_path.name:30s} {n} chunks")

    print(f"\n{total} chunks written to {chunks_dir}")


if __name__ == "__main__":
    main()
