#!/usr/bin/env python3
"""Tests for pandoc_fix_table_headers filter."""

import copy
import json
import subprocess
from pathlib import Path

import pytest

from pandoc_fix_table_headers import (
    fix_table_headers,
    is_header_empty,
    promote_first_row,
    row_is_blank,
)

SCRIPTS_DIR = Path(__file__).resolve().parent
FILTER = SCRIPTS_DIR / "pandoc_fix_table_headers.py"
DOCS_DIR = SCRIPTS_DIR.parent / "docs" / "swayfx"


# ---------------------------------------------------------------------------
# Helper builders for pandoc AST nodes
# ---------------------------------------------------------------------------

def _attr(id_="", classes=None, kvs=None):
    return [id_, classes or [], kvs or []]


def _cell(blocks, align="AlignDefault", rowspan=1, colspan=1):
    return [_attr(), {"t": align}, rowspan, colspan, blocks]


def _plain_text(s):
    return [{"t": "Plain", "c": [{"t": "Str", "c": s}]}]


def _row(cell_texts):
    cells = [_cell(_plain_text(t)) for t in cell_texts]
    return [_attr(), cells]


def _empty_row(n_cells):
    cells = [_cell([]) for _ in range(n_cells)]
    return [_attr(), cells]


def _table(head_rows, body_rows, colspecs=None):
    n_cols = len(body_rows[0][1]) if body_rows else 0
    if colspecs is None:
        colspecs = [[{"t": "AlignDefault"}, {"t": "ColWidthDefault"}]] * n_cols
    table_head = [_attr(), head_rows]
    table_body = [_attr(), 0, [], body_rows]
    table_foot = [_attr(), []]
    caption = [None, []]
    return {
        "t": "Table",
        "c": [_attr(), caption, colspecs, table_head, [table_body], table_foot],
    }


def _doc(blocks):
    return {
        "pandoc-api-version": [1, 23, 1],
        "meta": {},
        "blocks": blocks,
    }


# ---------------------------------------------------------------------------
# Unit tests
# ---------------------------------------------------------------------------

class TestIsHeaderEmpty:
    def test_empty(self):
        assert is_header_empty([_attr(), []]) is True

    def test_non_empty(self):
        assert is_header_empty([_attr(), [_row(["A"])]]) is False


class TestRowIsBlank:
    def test_blank(self):
        assert row_is_blank(_empty_row(3)) is True

    def test_non_blank(self):
        assert row_is_blank(_row(["A", "B"])) is False


class TestPromoteFirstRow:
    def test_promotes_when_header_empty(self):
        header_row = _row(["Col1", "Col2", "Col3"])
        data_row = _row(["a", "b", "c"])
        table = _table([], [header_row, data_row])

        changed = promote_first_row(table)

        assert changed is True
        head_rows = table["c"][3][1]
        body_rows = table["c"][4][0][3]
        assert len(head_rows) == 1
        assert len(body_rows) == 1
        # The promoted row should have "Col1" in the first cell
        first_cell_blocks = head_rows[0][1][0][4]
        assert first_cell_blocks[0]["c"][0]["c"] == "Col1"

    def test_no_change_when_header_present(self):
        existing_header = _row(["H1", "H2"])
        data_row = _row(["a", "b"])
        table = _table([existing_header], [data_row])
        original = copy.deepcopy(table)

        changed = promote_first_row(table)

        assert changed is False
        assert table == original

    def test_no_change_when_body_empty(self):
        table = _table([], [])

        changed = promote_first_row(table)

        assert changed is False

    def test_no_change_when_first_row_blank(self):
        blank = _empty_row(2)
        data = _row(["a", "b"])
        table = _table([], [blank, data])

        changed = promote_first_row(table)

        assert changed is False
        # blank row should still be in body
        assert len(table["c"][4][0][3]) == 2

    def test_no_change_when_no_body(self):
        table = _table([], [])
        # Remove all table bodies
        table["c"][4] = []

        changed = promote_first_row(table)

        assert changed is False


class TestFixTableHeaders:
    def test_fixes_multiple_tables(self):
        t1 = _table([], [_row(["A", "B"]), _row(["1", "2"])])
        t2 = _table([], [_row(["X", "Y"]), _row(["3", "4"])])
        para = {"t": "Para", "c": [{"t": "Str", "c": "text"}]}
        doc = _doc([t1, para, t2])

        fix_table_headers(doc)

        for t in [t1, t2]:
            assert len(t["c"][3][1]) == 1  # header has 1 row
            assert len(t["c"][4][0][3]) == 1  # body lost 1 row

    def test_skips_non_table_blocks(self):
        para = {"t": "Para", "c": [{"t": "Str", "c": "hello"}]}
        doc = _doc([para])
        original = copy.deepcopy(doc)

        fix_table_headers(doc)

        assert doc == original


# ---------------------------------------------------------------------------
# Integration: run the filter through pandoc on real man page data
# ---------------------------------------------------------------------------

class TestIntegrationWithPandoc:
    """Integration tests using real man page data via distrobox.

    The empty-header problem only occurs when converting from man/troff
    format. GFM tables always have headers syntactically, so reading GFM
    back through pandoc produces populated headers. These tests use the
    raw troff source to exercise the actual pipeline.
    """

    TROFF_SNIPPET = r""".TS
allbox;
lb lb lb
l l l.
TYPE NUMBER	MESSAGE	PURPOSE
0	RUN_COMMAND	Run a command
1	GET_WORKSPACES	Get workspace list
.TE
"""

    @pytest.fixture
    def man_json_ast(self):
        """Convert a troff table snippet to pandoc JSON AST."""
        result = subprocess.run(
            ["pandoc", "-f", "man", "-t", "json"],
            input=self.TROFF_SNIPPET,
            capture_output=True, text=True,
        )
        if result.returncode != 0:
            pytest.skip(f"pandoc man->json failed: {result.stderr}")
        return json.loads(result.stdout)

    def test_man_tables_have_empty_headers(self, man_json_ast):
        """Verify the problem exists: man-format tables have empty headers."""
        tables = [b for b in man_json_ast["blocks"] if b["t"] == "Table"]
        assert len(tables) > 0
        for t in tables:
            assert is_header_empty(t["c"][3])

    def test_filter_fixes_man_tables(self, man_json_ast):
        """Apply the filter and verify headers are populated."""
        fix_table_headers(man_json_ast)

        tables = [b for b in man_json_ast["blocks"] if b["t"] == "Table"]
        for t in tables:
            assert not is_header_empty(t["c"][3]), (
                "Table still has empty header after filter"
            )
            # Body should have lost one row
            body_rows = t["c"][4][0][3]
            assert len(body_rows) == 2  # was 3, now 2

    def test_roundtrip_to_gfm(self, man_json_ast):
        """Filter then convert to GFM — tables should render with headers."""
        fix_table_headers(man_json_ast)

        result = subprocess.run(
            ["pandoc", "-f", "json", "-t", "gfm"],
            input=json.dumps(man_json_ast),
            capture_output=True, text=True,
        )
        assert result.returncode == 0
        gfm = result.stdout
        # GFM tables have a separator line (e.g. |---|, |:---|, | --- |)
        assert "|---" in gfm or "|:--" in gfm
        assert "TYPE NUMBER" in gfm

    def test_stdin_filter_mode(self, man_json_ast):
        """Run the filter as a subprocess reading JSON from stdin."""
        filter_result = subprocess.run(
            ["python3", str(FILTER)],
            input=json.dumps(man_json_ast),
            capture_output=True, text=True,
        )
        assert filter_result.returncode == 0

        doc = json.loads(filter_result.stdout)
        tables = [b for b in doc["blocks"] if b["t"] == "Table"]
        for t in tables:
            assert not is_header_empty(t["c"][3]), (
                "Table still has empty header after filter"
            )
