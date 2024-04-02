#!/usr/bin/env python3
# Path: path/to/your_script.py
# -*- coding: utf-8 -*-


import argparse
import subprocess
from subprocess import PIPE
import os
import sys

from config import Config


def main(notes_dir: str, editor: str) -> None:
    pass


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

    args = parser.parse_args()

    main(args.notes_dir, args.editor)
