#!/usr/bin/env python3
# Path: path/to/your_script.py
# -*- coding: utf-8 -*-


from tqdm import tqdm
from filename_move import move_file
import os
import argparse

# This is a double walk so O(N^2), I could probably build up a dictionary of links
# and then only act on those, but this is a quick script and this approach
# is easier to maintain and extend from others.

ignores = [".py", ".json", ".js"]


def main():
    make_lower()


def make_lower():
    # Walk the file tree
    for root, dirs, files in os.walk("."):
        for file in tqdm(files):
            os.chdir("/home/ryan/Notes/slipbox")
            _, ext = os.path.splitext(file)
            if ext in ignores:
                continue
            filepath = os.path.join(root, file)
            os.makedirs(os.path.dirname(filepath), exist_ok=True)
            try:
                move_file(filepath, filepath.lower())
                # os.remove(os.path.dirname(filepath))
            except Exception as e:
                print(f"Error: {e}")
                continue


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description=(
            "Converts all files in a directory to" " lower case and update links"
        )
    )

    parser.add_argument("--dir", type=str, help="Directory containing note files")

    args = parser.parse_args()
    dir = args.dir
    os.chdir(dir)
    main()
