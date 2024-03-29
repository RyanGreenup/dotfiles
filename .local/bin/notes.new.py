#!/usr/bin/env python3

import sys
from utils import title_to_path, heirarchical_join
import os
from subprocess import PIPE
import subprocess

EDITOR = "nvim"


HOME = os.getenv("HOME")
assert HOME, "HOME var unavailable"

if len(sys.argv) > 1:
    notes_dir = sys.argv[1]
else:
    notes_dir = f"{HOME}/Notes/slipbox"


def main():
    files = get_files()
    files = get_root_heirarcy(files)
    root = choose_file_fzf(list(files))

    # Get Title from the user
    title = input("Enter Note Title: ")

    # Build the full path
    base_path = title_to_path(title)
    rel_path = heirarchical_join(root, base_path)
    full_path = os.path.join(notes_dir, rel_path)

    print(full_path)
    subprocess.run([EDITOR, full_path])


def get_root_heirarcy(files: list[str]) -> set[str]:
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
    parents = {f.replace(f"{notes_dir}/", "") for f in parents}

    return parents


def choose_file_fzf(parents: list[str]):
    # Let the user choose 1 with fzf
    fzf_cmd = "fzf"
    root = subprocess.run(
        fzf_cmd, text=True, input="\n".join(parents), stdout=PIPE, shell=True
    )
    root = root.stdout.strip()
    return root


def get_files() -> list[str]:
    """Get a list of files, shelling out"""
    pattern = r"\.md$"
    cmd = ["fd", pattern, notes_dir]
    out = subprocess.run(cmd, text=True, stdout=PIPE, shell=False)
    files = out.stdout.strip()
    return files.splitlines()


def remove_ext(f):
    return os.path.splitext(f)[0]


if __name__ == "__main__":
    main()
