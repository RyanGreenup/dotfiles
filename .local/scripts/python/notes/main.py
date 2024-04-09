#!/usr/bin/env python3
# Path: /home/ryan/.local/scripts/python/main.py
# -*- coding: utf-8 -*-

"""
This is a collection of shell scripts moved into a single python project.

Each file should be a command line tool that can be run from the command line.
It should also be accessible to a main.py file that can be run from the command
line as a CLI.

There is also a rust one at ../rust, this is a labor of love to rust using
both duct and clap.
"""


import typer
import new
import subprocess
import os
import make_link
import search
import find
import journals__open
import backlinks
from config import Config
from enum import Enum

app = typer.Typer()
config = Config.default()


def todo(s: str):
    print("TODO: ", s)


@app.command()
def New(notes_dir: str = config.notes_dir,
        editor: str = config.editor) -> None:
    new.main(notes_dir, editor)


@app.command()
def Search(notes_dir: str = config.notes_dir,
           editor: str = config.editor) -> None:
    search.main("", notes_dir, editor, config.search_cache_dir,
                context=False, fzf=True)


# Note: This doesn't follow the convention of the other scripts
#       I couldn't be bothered to rewrite it and it's a work in progress
@app.command()
def Sem():
    exe = os.path.join(os.path.dirname(__file__), "search__semantic.py")
    subprocess.run([exe], check=False)


@app.command()
def reindex(
        notes_dir: str = config.notes_dir,
        editor: str = config.editor,
        cache_dir: str = config.search_cache_dir):
    search.main("", notes_dir, editor, cache_dir,
                reindex=True, context=False)


@app.command()
def init(
        notes_dir: str = config.notes_dir,
        cache_dir: str = config.search_cache_dir):
    search.init_tantivy(cache_dir, clobber=True)
    search.index_tantivy(notes_dir, cache_dir)


@app.command()
def index(
        notes_dir: str = config.notes_dir,
        cache_dir: str = config.search_cache_dir):
    search.index_tantivy(notes_dir, cache_dir)


@app.command()
def Find(notes_dir: str = config.notes_dir,
         editor: str = config.editor) -> None:
    find.main(notes_dir, editor)


@app.command()
def Backlinks(file: str,
              notes_dir: str = config.notes_dir,
              editor: str = config.editor,
              relative: bool = False
              ) -> None:
    backlinks.main(file, notes_dir, editor, relative)
    # print(backlinks.grep_backlinks(file, notes_dir, relative))


@app.command()
def Open_journal(notes_dir: str = config.notes_dir,
                 editor: str = config.editor) -> None:
    journals__open.main(notes_dir, editor)


# This is a lazy way to do subcommands
class JournalCommand(Enum):
    Open = "open"
    Viz = "viz"


@app.command()
def Thing(sub_command: JournalCommand):
    match sub_command:
        case JournalCommand.Open:
            print("Open")
        case JournalCommand.Viz:
            print("Viz")


@app.command()
def Link(notes_dir: str = config.notes_dir) -> None:
    make_link.main(notes_dir)


if __name__ == "__main__":
    app()
