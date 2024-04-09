#!/usr/bin/env python3
# Path: path/to/your_script.py
# -*- coding: utf-8 -*-


import argparse
import subprocess
import os
from utils import gui_select, get_files, fzf_select

from config import Config


def main(notes_dir: str, editor: str | None, gui: bool = False) -> None:
    old_dir = os.getcwd()
    os.chdir(notes_dir)
    journals = list_journals(notes_dir)
    journals = [os.path.relpath(j, notes_dir) for j in journals]
    if gui:
        journal = os.path.abspath(gui_select(journals))
    else:
        journal = fzf_select(journals, multi=False)
        journal = os.path.abspath(journal.pop())
    if editor:
        subprocess.run([editor, journal])
    print(journal)
    os.chdir(old_dir)


def list_journals(dir: str) -> list[str]:
    files = get_files(dir)
    files = [f for f in files if "journal" in f]
    # sort by mtime
    files.sort(key=os.path.getmtime)
    files = files[::-1]
    return files


if __name__ == "__main__":
    config = Config.default()
    parser = argparse.ArgumentParser(description="Create a New Note")
    parser.add_argument(
        "--editor",
        type=str, help="Editor to open for the new note",
        default=config.editor
    )
    parser.add_argument(
        "--notes_dir",
        type=str, help="Notes Directory",
        default=config.notes_dir
    )
    parser.add_argument(
        "--gui",
        "-g",
        action="store_true",
        help="Use a GUI selector like Rofi",
        default=False
    )

    args = parser.parse_args()

    main(args.notes_dir, args.editor, args.gui)
