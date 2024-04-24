#!/usr/bin/env python3
# Path: path/to/your_script.py
# -*- coding: utf-8 -*-

"""
Moves a file to a new location and updates links. The links are updated in the
directories with a correct relative path.

If all notes are certainly flat, one could simply use `sed`:

    # Set parameters
    a=shiny__basic-structure.md
    b=r_code_shiny_basic-structure.md

    # Logic
    sed "s/$a/$b/g" -i *.md
    mv $a $b
"""

import os
import filename_sed
import argparse
import re

os.chdir(os.path.realpath(os.path.dirname(__file__)))
os.chdir("..")

ignores = [".py", ".json", ".js"]


def main(args):
    from_file = args.from_file
    to_file = args.to_file
    move_file(from_file, to_file)


def move_file(from_file, to_file):
    root_dir = os.getcwd()
    # Walk the file tree
    for root, dirs, files in os.walk("."):
        for file in files:
            _, ext = os.path.splitext(file)
            if ext in ignores:
                continue
            filepath = os.path.join(root, file)
            this_dir = os.path.dirname(filepath)
            # Change to the file's directory
            from_file_rel = os.path.relpath(from_file, this_dir)
            to_file_rel = os.path.relpath(to_file, this_dir)
            try:
                os.chdir(this_dir)
            except FileNotFoundError:
                print(f"Directory {this_dir} not found")
                continue
            # Make the from_file relative, that's what we're looking for
            # Replace the filename in all the files
            # (can do this in the same walk, same logic)
            replace_char_in_link(filepath, from_file_rel, to_file_rel)
    os.chdir(root_dir)
    # Move the file
    os.rename(from_file, to_file)


# from_file = "/Users/username/Downloads/notes/2021-01-01.md"
# current_file = "/Users/username/Downloads/notes/foo/file.md"
# this_dir = os.path.dirname(current_file)
# # ../2021-01-01.md
# os.path.relpath(from_file, this_dir)


def decompose(file):
    dir = os.path.dirname(file)
    base = os.path.basename(file)
    # Get extension
    stem, ext = os.path.splitext(base)
    return dir, base, stem, ext


def transform_url(content: str, from_file: str, to_file: str) -> str:
    url_regex = re.compile(r"\[.*?\]\((.*?)\)")

    transform_result = content
    # Handled rel stuff above because I was having a hard time
    # links = re.findall(url_regex, content)
    # for link in links:
    #     path, filename = os.path.split(link)
    #     file_stem, ext = os.path.splitext(filename)
    #     new_filename = file_stem.replace(from_file, to_file) + ext
    #     new_link = os.path.join(path, new_filename)
    transform_result = transform_result.replace(from_file, to_file)

    return transform_result


def replace_char_in_link(file, from_file, to_file):
    if file.endswith(".md"):
        with open(file, "r") as f:
            content = f.read()

        with open(file, "w") as f:
            f.write(transform_url(content, from_file, to_file))


def rename_file_replace_char(file, from_file, to_file):
    dir, base, stem, ext = decompose(file)
    new_stem = stem.replace(from_file, to_file)
    new_base = new_stem + ext
    new_path = os.path.join(dir, new_base)
    if new_path != file:
        print(f"Renaming {file} to {new_path}")
        # Rename the file
        os.rename(file, new_path)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Move a file and update links in relative paths"
    )

    parser.add_argument("--from-file", type=str, help="Character to remove")
    parser.add_argument("--to-file", type=str,
                        help="Character to replace with")
    parser.add_argument("--dir", type=str,
                        help="Directory containing note files")

    args = parser.parse_args()
    dir = args.dir
    os.chdir(dir)
    main(args)
