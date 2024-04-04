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
    print("here")

    # Sentence case
    display_title = path_to_title(rel_link)

    # Now print it
    link = create_md_link(display_title, rel_link)
    pyperclip.copy(link)
    print(link)
    os.chdir(old_dir)


def main_all_py(notes_dir):
    old_dir = os.getcwd()
    os.chdir(notes_dir)
    # The target note is the path in the clipboard
    target = pyperclip.paste()
    files = get_files(notes_dir, relative=True)
    file = gui_select(files)
    file = os.path.relpath(file, os.path.basename(target))
    link = create_md_link(path_to_title(file), file)
    pyperclip.copy(link)
    os.chdir(old_dir)

    # This if-clause ensures the following code only runs
    # when this file is executed directly


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Add a description for your program")
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
        default=False
    )

    args = parser.parse_args()

    if args.gui:
        main_all_py(args.notes_dir)
    else:
        main(args.notes_dir)
