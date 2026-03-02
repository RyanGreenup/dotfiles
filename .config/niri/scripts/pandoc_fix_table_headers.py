#!/usr/bin/env python3
"""Pandoc JSON filter that promotes the first body row to header when empty.

Many man-page-to-markdown conversions produce tables with an empty TableHead
and the real header sitting as the first body row. This filter detects that
pattern and moves the row into the header position.

Usage:
    pandoc -f man -t gfm --filter scripts/pandoc_fix_table_headers.py input.1

Or as a standalone AST transform:
    cat ast.json | python3 scripts/pandoc_fix_table_headers.py > fixed.json
"""

import json
import sys


def is_header_empty(table_head: list) -> bool:
    """Check whether the TableHead has zero rows.

    TableHead structure: [Attr, [Row, ...]]
    """
    rows = table_head[1]
    return len(rows) == 0


def row_is_blank(row: list) -> bool:
    """Check whether every cell in a Row contains no inline content.

    Row structure: [Attr, [Cell, ...]]
    Cell structure: [Attr, Alignment, RowSpan, ColSpan, [Block, ...]]
    """
    cells = row[1]
    return all(len(cell[4]) == 0 for cell in cells)


def promote_first_row(table: dict) -> bool:
    """Move the first body row into an empty TableHead. Returns True if changed."""
    # Table.c = [Attr, Caption, [ColSpec], TableHead, [TableBody], TableFoot]
    table_head = table["c"][3]
    table_bodies = table["c"][4]

    if not is_header_empty(table_head):
        return False

    if not table_bodies:
        return False

    # TableBody structure: [Attr, RowHeadColumns, [IntermediateHead], [BodyRow, ...]]
    body = table_bodies[0]
    body_rows = body[3]

    if not body_rows:
        return False

    first_row = body_rows[0]

    # Only promote if the row actually has content
    if row_is_blank(first_row):
        return False

    # Move first body row into the header
    table_head[1] = [body_rows.pop(0)]
    return True


def fix_table_headers(doc: dict) -> dict:
    """Walk the AST and fix all tables with empty headers."""
    for block in doc.get("blocks", []):
        if block.get("t") == "Table":
            promote_first_row(block)
    return doc


def main() -> None:
    doc = json.load(sys.stdin)
    doc = fix_table_headers(doc)
    json.dump(doc, sys.stdout)


if __name__ == "__main__":
    main()
