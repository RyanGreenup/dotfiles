#!/usr/bin/env python3
# Path: path/to/your_script.py
# -*- coding: utf-8 -*-


import argparse
import subprocess
from subprocess import PIPE
import os
import sys

from config import Config
from utils import sk_cmd


def main(notes_dir: str, editor: str | None = None) -> None:
    out = sk_cmd(notes_dir, preview=True)
    if editor:
        os.chdir(notes_dir)
        subprocess.run([editor] + out)
    else:
        print("\n".join(out))


if __name__ == "__main__":
    config = Config.default()
    parser = argparse.ArgumentParser(
        description="Search Notes and create an index if needed")
    parser.add_argument(
        "--editor",
        "-e",
        type=str, help="Search the notes and create the index if necessary",
        default=None
    )
    parser.add_argument(
        "--notes_dir",
        type=str, help="Notes Directory",
        default=config.notes_dir
    )
    parser.add_argument(
        "--cache_dir",
        type=str, help="Index Directory for Tantivy",
        default=config.search_cache_dir
    )
    parser.add_argument(
        "--cache_file",
        type=str, help="Cache File for Tantivy",
        default=config.search_cache_file
    )

    # Deleting the directory and starting over is pretty cheap with tantivy
    # so it's a good default and simple
    parser.add_argument(
        "--reindex",
        action='store_true',
        help="Reindex the notes by deleting the directory and starting over"
    )

    parser.add_argument(
        "--context",
        "-c",
        action='store_true',
        help="Include the context of the search term in the output"
    )

    args = parser.parse_args()

    main(args.notes_dir, args.editor)
    # args.cache_file, args.reindex, args.context)
