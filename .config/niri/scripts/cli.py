#!/usr/bin/env python3
"""Unified CLI for documentation pipeline.

Commands chunk, index, and search markdown docs under a configurable
docs directory (default: docs/).

Usage:
    python3 scripts/cli.py --help
    python3 scripts/cli.py chunk --chunk-size 512
    python3 scripts/cli.py index
    python3 scripts/cli.py search "key bindings"
    python3 scripts/cli.py tui
"""

from pathlib import Path
from typing import Annotated, Optional

import typer

SCRIPTS_DIR = Path(__file__).resolve().parent
PROJECT_DIR = SCRIPTS_DIR.parent
DEFAULT_DOCS_DIR = PROJECT_DIR / "docs"

DocsDir = Annotated[
    Path,
    typer.Option(
        "--docs-dir", "-d",
        help="Path to the docs directory containing .md files.",
    ),
]

app = typer.Typer(
    name="docs",
    help="Documentation pipeline — chunk, index, and search markdown docs.",
    no_args_is_help=True,
)


@app.command()
def chunk(
    docs_dir: DocsDir = DEFAULT_DOCS_DIR,
    chunk_size: Annotated[
        int, typer.Option("--chunk-size", "-s", help="Max tokens per chunk.")
    ] = 512,
    overlap: Annotated[
        int, typer.Option("--overlap", "-o", help="Overlap characters before and after.")
    ] = 64,
) -> None:
    """Chunk markdown docs into smaller files using chonkie."""
    from chunk_markdown import main as chunk_main

    chunk_main(chunk_size=chunk_size, overlap=overlap, docs_dir=docs_dir)


@app.command()
def index(
    docs_dir: DocsDir = DEFAULT_DOCS_DIR,
    rebuild: Annotated[
        bool, typer.Option("--rebuild", "-r", help="Force rebuild the index from scratch.")
    ] = False,
) -> None:
    """Build a semantic search index over the doc chunks."""
    import shutil

    import lancedb
    from semantic_search import DB_DIR, TABLE_NAME, build_index, collect_chunks

    chunks_dir = docs_dir / "chunks"

    if rebuild and DB_DIR.exists():
        shutil.rmtree(DB_DIR)
        print(f"Removed existing index at {DB_DIR}")

    db = lancedb.connect(str(DB_DIR))

    if not rebuild and TABLE_NAME in db.list_tables().tables:
        table = db.open_table(TABLE_NAME)
        print(f"Index already exists with {table.count_rows()} rows at {DB_DIR}")
        print("Use --rebuild to force re-indexing.")
        return

    rows = collect_chunks(chunks_dir)
    if not rows:
        print(f"No chunks found in {chunks_dir}")
        print("Run `cli.py chunk` first.")
        raise typer.Exit(1)

    table = build_index(db, chunks_dir)
    print(f"Done — {table.count_rows()} chunks indexed.")


@app.command()
def search(
    query: Annotated[str, typer.Argument(help="Search query string.")],
    top_k: Annotated[
        int, typer.Option("--top-k", "-k", help="Number of results to return.")
    ] = 5,
    file: Annotated[
        Optional[str],
        typer.Option("--file", "-f", help="File whose content to use as query instead."),
    ] = None,
) -> None:
    """Search doc chunks by semantic similarity."""
    import lancedb
    from semantic_search import DB_DIR, TABLE_NAME, search as sem_search

    db = lancedb.connect(str(DB_DIR))

    if TABLE_NAME not in db.list_tables().tables:
        print("No index found. Run `cli.py index` first.")
        raise typer.Exit(1)

    table = db.open_table(TABLE_NAME)

    if file:
        file_path = Path(file)
        if not file_path.is_file():
            print(f"File not found: {file}")
            raise typer.Exit(1)
        query_text = file_path.read_text()
        if not query_text.strip():
            print(f"File is empty: {file}")
            raise typer.Exit(1)
    else:
        query_text = query

    results = sem_search(table, query_text, top_k)
    for r in results:
        dist = r["_distance"]
        path = r["path"]
        print(f"  {dist:.4f}  {path}")


@app.command()
def tui(
    docs_dir: DocsDir = DEFAULT_DOCS_DIR,
    rebuild: Annotated[
        bool, typer.Option("--rebuild", "-r", help="Rebuild the index before launching.")
    ] = False,
) -> None:
    """Launch the interactive TUI for searching docs."""
    from search_tui import SearchApp, _ensure_index

    chunks_dir = docs_dir / "chunks"
    table = _ensure_index(rebuild=rebuild, chunks_dir=chunks_dir)
    search_app = SearchApp(table, docs_dir=docs_dir)
    search_app.run()


if __name__ == "__main__":
    app()
