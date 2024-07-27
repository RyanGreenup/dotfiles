#!/usr/bin/env python3

import os
import duckdb as db
import polars as pl
from typing import Annotated
import typer
import json
import subprocess


TBL_NAME = "notes"
PATH_COLNAME = "path"
DEFUALT_DB_PATH = "/tmp/notesdb.duckdb"


app = typer.Typer()


@app.command()
def build_index(db_path: str = DEFUALT_DB_PATH, only_build_db: bool = False):
    """
    Build an index of a directory of markdown files.

    Automatically calls create_db()
    """
    df = build_dataframe()
    create_db(df, db_path)
    build_fts_index(db_path)


# NOTE works well with
# sk -m -i -c '~/.local/scripts/python/notes/duckdb-search.py search {}' --preview 'bat --color=always {+}'
# Consider adding a live search
@app.command()
def search(
    search_input: str,
    db_path: str = DEFUALT_DB_PATH,
    show_score: bool = False,
    relpath: bool = True,
):
    # TODO implement search input
    df = search_fts_index(db_path, search_input)
    if relpath:
        df = df.with_columns(
            pl.col(PATH_COLNAME).map_elements(
                lambda x: os.path.relpath(x, os.getcwd()),
                pl.String,
            )
        )
    if show_score:
        paths = list(df[PATH_COLNAME])
        scores = list(df["score"])
        for p, s in zip(paths, scores):
            print(f"{s}\t{p}")
    else:
        for p in df[PATH_COLNAME].reverse():
            print(p)


def build_dataframe(
    notes_dir: str = os.path.expanduser("~") + "/Notes/slipbox",
) -> pl.DataFrame:
    """
    Build a Dataframe of files and their contents in a directory.
    """

    d: dict[str, list[str]] = {"path": [], "title": [], "content": []}

    for root, _, files in os.walk(notes_dir):
        for file in files:
            if file.endswith(".md"):
                file_path = os.path.join(root, file)
                d["path"].append(file_path)
                with open(file_path, "r") as f:
                    lines = f.readlines()
                    if len(lines) > 0:
                        d["title"].append(lines[0].strip())
                    else:
                        d["title"].append("")
                    content = "".join(lines[1:])
                    d["content"].append(content)

    # TODO consider adding backlinks, see ./embed_backlinks.py
    # TODO consider calculating pagerank to sort by
    # TODO consider using LLM to infer tags
    df = pl.DataFrame(d)
    return df


def create_db(df: pl.DataFrame, path):
    """
    Build a DuckDB database of the form

    | Path | Title | Content |
    | ---- | ----- | ------- |
    | ...  | ...   | ...     |
    """
    with db.connect(path) as con:
        con.sql(f"DROP TABLE IF EXISTS {TBL_NAME};")
        con.sql(f"CREATE TABLE IF NOT EXISTS {TBL_NAME} AS SELECT * FROM df")
        con.close()

    # with db.connect(path) as con:
    #     print(con.sql(f"select * from notes where {PATH_COLNAME} like '%sql%'"))


def build_fts_index(db_path: str):
    """
    Build a full text search index from a table.
    """
    with db.connect(db_path) as con:
        con.sql("SHOW ALL TABLES")
        cmd = f"""PRAGMA create_fts_index(
                {TBL_NAME},
                {PATH_COLNAME},
                '*',
                stemmer = 'porter',
                stopwords = 'english',
                strip_accents = 1,
                lower = 1,
                overwrite = 1)"""
        con.sql(cmd)


def search_fts_index(db_path: str, search_input: str = "duckdb") -> pl.DataFrame:
    """
    See: <https://duckdb.org/docs/extensions/full_text_search.html>
    """
    # Note that the Table name is a part of the FTS index table name
    with db.connect(db_path) as con:
        cmd = f"""
        SELECT {PATH_COLNAME}, score
        FROM (
            SELECT *, fts_main_{TBL_NAME}.match_bm25(
                {PATH_COLNAME},
                '{search_input}'
            ) AS score
            FROM {TBL_NAME}
        ) sq
        WHERE score IS NOT NULL
        ORDER BY score DESC;
        """
        return con.sql(cmd).pl()


if __name__ == "__main__":
    app()


# with db.connect("/tmp/notesdb.duckdb") as con:
#     print(con.sql("SHOW ALL TABLES"))
#     print(con.sql("SELECT * FROM notes").pl())
