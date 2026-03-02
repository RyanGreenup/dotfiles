#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = ["lancedb", "sentence-transformers>=2.7.0", "torch"]
# ///
"""Search doc chunks by semantic similarity to a given file.

Indexes all markdown chunks under docs/chunks/ into a LanceDB table
with embeddings generated automatically by Qwen3-Embedding-4B, then
prints chunk filenames ranked by cosine distance to the query file.

Usage:
    python scripts/semantic_search.py <query_file> [--top-k N] [--rebuild]
"""

import argparse
import shutil
import sys
from pathlib import Path

import lancedb
from lancedb.embeddings import get_registry
from lancedb.pydantic import LanceModel, Vector

DOCS_DIR = Path(__file__).resolve().parent.parent / "docs"
CHUNKS_DIR = DOCS_DIR / "chunks"
DB_DIR = Path(__file__).resolve().parent.parent / ".lancedb"
TABLE_NAME = "chunks"
MODEL_NAME = "Qwen/Qwen3-Embedding-4B"


def _get_device() -> str:
    try:
        import torch
        return "cuda" if torch.cuda.is_available() else "cpu"
    except ImportError:
        return "cpu"


def _make_embedding_func():
    st = get_registry().get("sentence-transformers")
    return st.create(name=MODEL_NAME, device=_get_device())


embedding_func = _make_embedding_func()


class Chunk(LanceModel):
    text: str = embedding_func.SourceField()
    vector: Vector(embedding_func.ndims()) = embedding_func.VectorField()  # type: ignore[valid-type]
    path: str  # relative path from CHUNKS_DIR


def collect_chunks(chunks_dir: Path = CHUNKS_DIR) -> list[dict]:
    """Read all markdown chunk files into dicts for indexing."""
    rows = []
    for md in sorted(chunks_dir.rglob("*.md")):
        text = md.read_text()
        if not text.strip():
            continue
        rel = str(md.relative_to(chunks_dir))
        rows.append({"text": text, "path": rel})
    return rows


def build_index(
    db: lancedb.DBConnection, chunks_dir: Path = CHUNKS_DIR
) -> lancedb.table.Table:
    """Create the table and index all chunks."""
    rows = collect_chunks(chunks_dir)
    if not rows:
        print("No chunks found in", chunks_dir, file=sys.stderr)
        sys.exit(1)

    print(f"Indexing {len(rows)} chunks with {MODEL_NAME} on {_get_device()}...")
    table = db.create_table(TABLE_NAME, schema=Chunk, mode="overwrite")
    table.add(rows)
    print(f"Indexed {len(rows)} chunks into {DB_DIR}")
    return table


def search(table: lancedb.table.Table, query_text: str, top_k: int) -> list[dict]:
    """Search the table by query text, return results with distance."""
    return (
        table.search(query_text)
        .distance_type("cosine")  # type: ignore[attr-defined]
        .limit(top_k)
        .to_list()
    )


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Search doc chunks by semantic similarity to a file."
    )
    parser.add_argument("query_file", type=Path, help="File to use as query")
    parser.add_argument("--top-k", type=int, default=20, help="Number of results")
    parser.add_argument(
        "--rebuild", action="store_true", help="Force rebuild the index"
    )
    args = parser.parse_args()

    if not args.query_file.is_file():
        print(f"File not found: {args.query_file}", file=sys.stderr)
        sys.exit(1)

    query_text = args.query_file.read_text()
    if not query_text.strip():
        print("Query file is empty", file=sys.stderr)
        sys.exit(1)

    db = lancedb.connect(str(DB_DIR))

    if args.rebuild and DB_DIR.exists():
        shutil.rmtree(DB_DIR)
        db = lancedb.connect(str(DB_DIR))

    if TABLE_NAME in db.list_tables().tables:
        table = db.open_table(TABLE_NAME)
    else:
        table = build_index(db)

    results = search(table, query_text, args.top_k)

    for r in results:
        dist = r["_distance"]
        path = r["path"]
        print(f"  {dist:.4f}  {path}")


if __name__ == "__main__":
    main()
