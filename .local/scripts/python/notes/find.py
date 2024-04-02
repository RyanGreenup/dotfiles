#!/usr/bin/env python3
# Path: path/to/your_script.py
# -*- coding: utf-8 -*-


import argparse
from utils import fzf_select, get_files, open_in_editor, gui_select
import os
import find
import search

from config import Config


def main(notes_dir: str, editor: str, gui: bool = False) -> None:
    original_dir = os.getcwd()
    # CD for relative
    os.chdir(notes_dir)
    # Get all Files
    files = get_files(notes_dir, relative=True)
    if gui:
        files = [gui_select(files)]
    else:
        # Choose files
        files = fzf_select(files, True)
    # Open them
    open_in_editor(files, editor)
    # CD -
    os.chdir(original_dir)


if __name__ == "__main__":
    config = Config.default()
    parser = argparse.ArgumentParser(description="Find a Note with fzf")
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
        help="Notes Directory",
        default=config.notes_dir
    )

    args = parser.parse_args()

    main(args.notes_dir, args.editor, args.gui)
