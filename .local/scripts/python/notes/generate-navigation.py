#!/usr/bin/env python3
# Path: path/to/your_script.py
# -*- coding: utf-8 -*-

import os
import argparse
import sys


def generate_md(filepath):
    directories, filename = os.path.split(filepath)
    filename_without_ext = os.path.splitext(filename)[0]

    dir_parts = directories.split("/")[
        1:
    ]  # ignore the first directory (home directory)

    md_parts = []
    for i, part in enumerate(dir_parts):
        indent = "    " * i
        md_parts.append(f"{indent}- [{part.capitalize()}]({dir_parts[i]}_uhe.md)")

    filename_indent = "    " * len(dir_parts)

    md_parts.append(
        f"{filename_indent}- x [{filename_without_ext.replace('_', ' ').capitalize()}]({filename}.md)"
    )

    md_string = "\n".join(md_parts)
    full_md = (
        f"<details closed><summary><h2>🧭</h2></summary>\n\n{md_string}\n</details>"
    )

    return full_md


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--filepath", help="Path to file")
    args = parser.parse_args()

    filepath = args.filepath

    if filepath is None:
        filepath = sys.stdin.read().strip()

    print(generate_md(filepath))


if __name__ == "__main__":
    main()
