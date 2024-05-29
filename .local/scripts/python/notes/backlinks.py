#!/usr/bin/env python3
# Path: path/to/your_script.py
# -*- coding: utf-8 -*-


import argparse
import re
from collections import defaultdict
import subprocess
from subprocess import PIPE
import os
import sys
from utils import fzf_select

from config import Config


def main(file: str, notes_dir: str, editor: str, relative: bool) -> None:
    backlinks = get_backlinks(file, notes_dir)
    files = fzf_select(list(backlinks), True)
    subprocess.run([editor] + files, check=True)


def print_backlinks(file: str, notes_dir: str, relative: bool = False) -> None:
    backlinks = get_backlinks(notes_dir, file)
    for b in backlinks:
        if relative:
            b = os.path.relpath(b, notes_dir)
        print(b)


def grep_backlinks(file: str, notes_dir: str, relative: bool = True) -> set:
    """Use Grep to find backlinks. This is faster than building an entire
    dictionary as with build_backlinks"""
    old_dir = os.getcwd()
    os.chdir(notes_dir)
    out = subprocess.run(["rg", "-l", file],
                         stdout=subprocess.PIPE,
                         text=True,
                         check=True)
    files = set(out.stdout.splitlines())
    if relative:
        files = {os.path.abspath(f) for f in files}
    os.chdir(old_dir)
    return files


def get_backlinks(file: str, notes_dir: str) -> set:
    """Get the backlinks for a single file.
    """
    file = os.path.basename(file)
    backlinks = build_backlinks(notes_dir)
    return backlinks[file]


def build_backlinks(notes_dir: str) -> dict:
    """Build a dictionary of backlinks from the notes directory.

    This may slow down for a large number of notes (>= 3000). If that's the
    case just grep for the name of the note in the notes directory, they're
    flat so this should work fine and be faster."""
    # Pattern to get markdown links
    link_pattern = re.compile(r"\[.*?\]\((.*?)\.md\)")

    # empty dictionary
    backlinks = defaultdict(set)

    # Loop over all files in the notes directory
    for root, _, files in os.walk(notes_dir):
        for file in files:
            # Only process markdown files as extension is hardcoded
            if file.endswith(".md"):
                file_path = os.path.join(root, file)
                # Remove unwanted stuff
                for bad in [".unison.", ".DS_Store", "sync-conflict"]:
                    if bad in file_path:
                        continue
                # Open the file
                with open(file_path, "r") as f:
                    # Get the links
                    content = f.read()
                    links = link_pattern.findall(content)
                    # Add each link to the backlinks dictionary
                    for link in links:
                        # Add but don't split on whitespace
                        backlinks[link +
                                  ".md"].add(file_path.replace(" ", "%20"))

    # Remove entries that aren't under the notes directory
    backlinks = {file: backlinks[file]
                 for file in backlinks if file in backlinks}

    return backlinks


if __name__ == "__main__":
    config = Config.default()
    parser = argparse.ArgumentParser(
        description="Get Backlinks from a Given Note")
    parser.add_argument(
        "file",
        type=str, help="Editor to open for the new note")
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
        "--relative", "-r",
        type=str, help="Relative Paths",
        default=config.notes_dir
    )

    args = parser.parse_args()

    main(args.file, args.notes_dir, args.editor, args.relative)
