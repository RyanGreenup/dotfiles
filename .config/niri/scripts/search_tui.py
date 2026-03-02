#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "lancedb",
#     "sentence-transformers>=2.7.0",
#     "textual>=3.0",
#     "torch",
# ]
# ///
"""TUI for searching doc chunks by semantic similarity.

Keeps the embedding model loaded in memory for fast subsequent searches.
Select a doc file from the sidebar, view the top-10 matching chunks,
and copy the results to the clipboard.

Usage:
    python scripts/search_tui.py [--rebuild]
"""

import subprocess
import sys
from pathlib import Path

import lancedb
from lancedb.embeddings import get_registry
from lancedb.pydantic import LanceModel, Vector
from textual import work
from textual.app import App, ComposeResult
from textual.binding import Binding
from textual.widgets import Footer, Header, OptionList, RichLog, Static
from textual.widgets.option_list import Option

PROJECT_DIR = Path(__file__).resolve().parent.parent
DEFAULT_DOCS_DIR = PROJECT_DIR / "docs"
DB_DIR = PROJECT_DIR / ".lancedb"
TABLE_NAME = "chunks"
MODEL_NAME = "Qwen/Qwen3-Embedding-4B"
TOP_K = 10


# ---------------------------------------------------------------------------
# Embedding setup (runs once at import time so the model stays loaded)
# ---------------------------------------------------------------------------

def _get_device() -> str:
    try:
        import torch
        return "cuda" if torch.cuda.is_available() else "cpu"
    except ImportError:
        return "cpu"


_st = get_registry().get("sentence-transformers")
_embedding_func = _st.create(name=MODEL_NAME, device=_get_device())


class Chunk(LanceModel):
    text: str = _embedding_func.SourceField()
    vector: Vector(_embedding_func.ndims()) = _embedding_func.VectorField()  # type: ignore[valid-type]
    path: str


# ---------------------------------------------------------------------------
# Index helpers
# ---------------------------------------------------------------------------

def _ensure_index(
    rebuild: bool = False,
    chunks_dir: Path = DEFAULT_DOCS_DIR / "chunks",
) -> lancedb.table.Table:
    db = lancedb.connect(str(DB_DIR))

    if not rebuild and TABLE_NAME in db.list_tables().tables:
        return db.open_table(TABLE_NAME)

    rows = []
    for md in sorted(chunks_dir.rglob("*.md")):
        text = md.read_text()
        if text.strip():
            rows.append({"text": text, "path": str(md.relative_to(chunks_dir))})

    if not rows:
        print("No chunks found in", chunks_dir, file=sys.stderr)
        sys.exit(1)

    table = db.create_table(TABLE_NAME, schema=Chunk, mode="overwrite")
    table.add(rows)
    return table


def _search(table: lancedb.table.Table, query: str) -> list[dict]:
    return (
        table.search(query)
        .distance_type("cosine")  # type: ignore[attr-defined]
        .limit(TOP_K)
        .to_list()
    )


def _copy_to_system_clipboard(text: str) -> None:
    """Copy text using wl-copy (Wayland) with fallback to xclip."""
    for cmd in (["wl-copy"], ["xclip", "-selection", "clipboard"]):
        try:
            subprocess.run(cmd, input=text.encode(), check=True)
            return
        except FileNotFoundError:
            continue


# ---------------------------------------------------------------------------
# TUI
# ---------------------------------------------------------------------------

class SearchApp(App):
    TITLE = "doc search"
    CSS = """
    #sidebar {
        width: 30;
        dock: left;
        border-right: solid $accent;
    }
    #results {
        width: 1fr;
    }
    #status {
        dock: bottom;
        height: 1;
        background: $boost;
        color: $text-muted;
        padding: 0 1;
    }
    """
    BINDINGS = [
        Binding("q", "quit", "Quit"),
        Binding("r", "rebuild", "Rebuild index"),
    ]

    def __init__(
        self,
        table: lancedb.table.Table,
        docs_dir: Path = DEFAULT_DOCS_DIR,
    ) -> None:
        super().__init__()
        self._table = table
        self._docs_dir = docs_dir
        self._last_results: list[dict] = []

    def compose(self) -> ComposeResult:
        yield Header()
        doc_files = sorted(
            f.name for f in self._docs_dir.iterdir() if f.is_file() and f.suffix == ".md"
        )
        yield OptionList(
            *[Option(name, id=name) for name in doc_files],
            id="sidebar",
        )
        yield RichLog(id="results", highlight=True, markup=True)
        yield Static("Select a doc file to search", id="status")
        yield Footer()

    def on_option_list_option_selected(
        self, event: OptionList.OptionSelected
    ) -> None:
        self._run_search(str(event.option.prompt))

    @work(exclusive=True, thread=True)
    def _run_search(self, filename: str) -> None:
        from textual.worker import get_current_worker

        worker = get_current_worker()

        self.call_from_thread(self._set_status, f"Searching for {filename}...")

        query_text = (self._docs_dir / filename).read_text()
        if not query_text.strip():
            self.call_from_thread(self._set_status, f"{filename} is empty")
            return

        results = _search(self._table, query_text)
        if worker.is_cancelled:
            return

        self._last_results = results

        lines = [f"[bold]Results for {filename}[/bold]\n"]
        clipboard_lines = [f"Results for {filename}"]
        for r in results:
            dist = r["_distance"]
            path = r["path"]
            line = f"  {dist:.4f}  {path}"
            lines.append(line)
            clipboard_lines.append(line)

        clipboard_text = "\n".join(clipboard_lines)
        _copy_to_system_clipboard(clipboard_text)

        def update_ui() -> None:
            log = self.query_one("#results", RichLog)
            log.clear()
            for line in lines:
                log.write(line)
            self._set_status(f"{filename}: {len(results)} results (copied to clipboard)")

        self.call_from_thread(update_ui)

    def _set_status(self, text: str) -> None:
        self.query_one("#status", Static).update(text)

    def action_rebuild(self) -> None:
        self._set_status("Rebuilding index...")
        self._do_rebuild()

    @work(exclusive=True, thread=True)
    def _do_rebuild(self) -> None:
        chunks_dir = self._docs_dir / "chunks"
        table = _ensure_index(rebuild=True, chunks_dir=chunks_dir)
        self._table = table
        self.call_from_thread(
            self._set_status, "Index rebuilt. Select a file to search."
        )


def main() -> None:
    rebuild = "--rebuild" in sys.argv
    table = _ensure_index(rebuild=rebuild)
    app = SearchApp(table)
    app.run()


if __name__ == "__main__":
    main()
