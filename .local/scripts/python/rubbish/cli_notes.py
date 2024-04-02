#!/usr/bin/env python3
# Path: path/to/your_script.py
# -*- coding: utf-8 -*-

"""
Notes: Functions related to managing Notes
"""

import typer
# import new as New  # bad
import notes.new


app = typer.Typer()


@app.command()
def new(notes_dir: str, editor: str):
    notes.new.main(notes_dir, editor)


@app.command()
def backlinks(notes_dir: str):
    # notes.backlinks.main(notes_dir)
    todo("Implement backlinks")


@app.command()
def search(notes_dir: str):
    # notes.search.main(notes_dir)
    todo("Implement search")


@app.command()
def find(notes_dir: str):
    # notes.find.main(notes_dir)
    todo("Implement find")

@app.command()
def choose_journal(notes_dir: str, editor: str):
    notes.new.choose_journal(notes_dir, editor)


if __name__ == "__main__":
    app()
