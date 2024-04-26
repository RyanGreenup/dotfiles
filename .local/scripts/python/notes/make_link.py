#!/usr/bin/env python3
# Path: path/to/your_script.py
# -*- coding: utf-8 -*-

"""
A script to create links from a note path in the clipboard

TODO Switch to fzf or skim, the matching is better
"""

# Import necessary standard Python libraries
# import pytest
import argparse
import os
import subprocess
import pyperclip
from utils import gui_select, path_to_title, create_md_link, get_files
from config import Config

HOME = os.getenv("HOME")
assert HOME is not None, "HOME environment variable not set"
config = Config.default()


def main(notes_dir: str):
    old_dir = os.getcwd()
    os.chdir(notes_dir)

    # Get the clipboard contents, this is the note we are on
    filename = pyperclip.paste()

    # Replace the tilde with the home directory
    if filename.startswith("~"):
        filename = filename.replace("~", HOME)

    # Use the note_taking script to get the new note link
    # TODO just use fzf_select(get_files(notes_dir)) from utils.py
    cmd = ["note_taking", "-d", notes_dir, "link"]
    try:
        new_link_from_notes_dir = subprocess.run(
            cmd, capture_output=True, check=True, text=True
        ).stdout.strip()
    except subprocess.CalledProcessError as e:
        print(e.stderr)
        return
    except Exception as e:
        print(e)
        return

    start = os.path.dirname(os.path.abspath(filename))
    target = os.path.abspath(new_link_from_notes_dir)

    # Get the full path of the new link
    rel_link = os.path.relpath(target, start)
    rel_link = rel_link.replace(" ", "%20")

    # Sentence case
    display_title = path_to_title(rel_link)

    # Now print it
    link = create_md_link(display_title, rel_link)
    pyperclip.copy(link)
    print(link)
    os.chdir(old_dir)


def relpath(target_note: str, note_editing: str) -> str:
    return os.path.relpath(
        path=target_note,
        start=os.path.dirname(os.path.abspath(note_editing)),
    )


def main_all_py(notes_dir, current_note: str):
    old_dir = os.getcwd()
    os.chdir(notes_dir)
    # The target note is the path in the clipboard
    files = get_files(notes_dir, relative=True)
    file = gui_select(files)
    file = relpath(file, current_note)
    title = path_to_title(file)
    file = file.replace(" ", "%20")
    link = create_md_link(title, file)
    pyperclip.copy(link)
    os.chdir(old_dir)
    print(link)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Takes a link to a note in the clipboard and creates a relative link to another note"
    )
    parser.add_argument(
        "--notes_dir",
        type=str,
        help="The directory of the notes",
        default=config.notes_dir,
    )
    parser.add_argument(
        "--gui",
        "-g",
        action="store_true",
        help="Use a Gui to select the note to create the link",
        default=False,
    )
    parser.add_argument(
        "-c",
        "--current_note",
        type=str,
        help="The note you are currently on (Takes clipboard if not provided)",
        default=None,
    )

    args = parser.parse_args()

    if not args.current_note:
        current_note = pyperclip.paste()
    else:
        current_note = args.current_note

    if args.gui:
        main_all_py(args.notes_dir, current_note)
    else:
        main(args.notes_dir)
