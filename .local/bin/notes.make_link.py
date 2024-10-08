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
import sys
import os
import subprocess
import pyperclip
from utils import path_to_title, create_md_link

HOME = os.getenv("HOME")
assert HOME is not None, "HOME environment variable not set"


def note_taking_link(notes_dir: str):

    # Get the clipboard contents, this is the note we are on
    filename = pyperclip.paste()

    # Replace the tilde with the home directory
    if filename.startswith("~"):
        filename = filename.replace("~", HOME)

    # Use the note_taking script to get the new note link
    cmd = ["note_taking", "-d", notes_dir, "link"]
    new_link_from_notes_dir = subprocess.run(
        cmd, capture_output=True, check=True, text=True
    ).stdout.strip()

    # Get the full path of the new link
    new_link = os.path.join(notes_dir, new_link_from_notes_dir)
    new_link = os.path.abspath(new_link)
    # Get the relative path
    rel_link = os.path.relpath(new_link, os.path.dirname(filename))

    # Sentence case
    display_title = path_to_title(rel_link)

    # Now print it
    link = create_md_link(display_title, rel_link)
    pyperclip.copy(link)
    print(link)


def main(args):
    """
    The core function that encapsulates all tasks performed by this script.
    Args can be parsed during runtime using the argparse module.
    """
    if args.nl:
        if args.notes_dir:
            note_taking_link(args.notes_dir)
        else:
            notes_dir = f"{HOME}/slipbox"
            print(f"No directory given, defaulting to {notes_dir}")
            note_taking_link(notes_dir)


# This if-clause ensures the following code only runs
# when this file is executed directly
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Add a description for your program")
    parser.add_argument("--nl", action="store_true", help="Run note_taking link")
    parser.add_argument("--notes_dir", type=str, help="The directory of the notes")
    args = parser.parse_args()
    main(args)
