#!/usr/bin/env python3
# Path: path/to/your_script.py
# -*- coding: utf-8 -*-


import argparse
import subprocess
from subprocess import PIPE
import os
from utils import title_to_path, heirarchical_join
import sys

from config import Config


def main(notes_dir: str, editor: str) -> None:
    files = get_files(notes_dir)
    files = get_root_heirarcy(files, notes_dir)
    root = choose_file_fzf(list(files))

    # Get Title from the user
    title = input("Enter Note Title (With Capitals etc.): ")

    # Build the full path
    base_path = title_to_path(title)
    rel_path = heirarchical_join(root, base_path)
    full_path = os.path.join(notes_dir, rel_path)

    # Check if the file exists
    if os.path.exists(full_path):
        print("File already exists", file=sys.stderr)
    else:
        with open(full_path, "w") as f:
            f.write("# " + title + "\n\n")
    print(full_path)
    subprocess.run([editor, full_path])


def get_root_heirarcy(files: list[str], dir: str) -> set[str]:
    """similar to dirname, however uses "."
    Applies this to each element in a list and returns
    unique heirarchies
    Example:
        input:  Code/MWE/python.foo.bar.my-notes-on-this.md
        output: Code/MWE/python.foo.bar
    """
    parents = set(files)
    # Remove the extension from the parents
    parents = {remove_ext(f) for f in parents}
    # Remove the file name and keep only domain
    # Keep only Unique
    parents = {remove_ext(f) for f in parents}
    # Strip the path
    parents = {f.replace(f"{dir}/", "") for f in parents}

    return parents


def choose_file_fzf(parents: list[str]):
    # Let the user choose 1 with fzf
    fzf_cmd = "fzf"
    root = subprocess.run(
        fzf_cmd,
        text=True,
        input="\n".join(parents),
        stdout=PIPE,
        shell=True,
        check=True)
    root = root.stdout.strip()
    return root


def get_files(dir: str) -> list[str]:
    """Get a list of files, shelling out"""
    pattern = r"\.md$"
    cmd = ["fd", pattern, dir]
    out = subprocess.run(cmd, text=True, stdout=PIPE, shell=False)
    files = out.stdout.strip()
    return files.splitlines()


def remove_ext(f):
    return os.path.splitext(f)[0]


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
