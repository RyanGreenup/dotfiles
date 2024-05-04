#!/usr/bin/env python3
# Path: ~/.local/scripts/python/notes/generate-navigation.py
# -*- coding: utf-8 -*-

import os
import argparse
from config import Config
import sys

config = Config.default()


def filename_to_markdown(file_path):
    file_path = os.path.relpath(path=file_path, start=config.notes_dir)

    # Remove extension and make relative to base directory
    file_path = os.path.splitext(file_path.replace("~/Notes/slipbox/", ""))[0]

    # Split into hierarchy
    sections = file_path.replace("_", "/").split("/")

    markdown = "<details closed><summary><h2>🧭</h2></summary>\n"
    # Add a space before the newline so lua gmatch has an easier time
    # see ~/.config/nvim/lua/utils/markdown.lua
    markdown += " \n"

    for i in range(len(sections)):
        # Use '-' to split words, and capitalize each word
        title = " ".join(word.capitalize() for word in sections[i].split("-"))

        # Create filename by joining sections with '_'
        filename = "_".join(sections[: i + 1]) + ".md"

        # Use '*' for the current file (last section)
        prefix = "- x" if i == len(sections) - 1 else "-"

        # Depending on the depth(i), we indent the bullet point more
        markdown += "    " * i + f"{prefix} [{title}]({filename})\n"

    markdown += "</details>"
    return markdown


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Process filepath.")
    parser.add_argument("filepath", nargs="?", type=str, default=None)
    args = parser.parse_args()

    if not (filepath := args.filepath):
        filepath = sys.stdin.read().strip()
    print(filename_to_markdown(filepath))
