#!/usr/bin/env python3
# Path: path/to/your_script.py
# -*- coding: utf-8 -*-
import os
import argparse
import re

from_char = "."
to_char = "__"

ignores = [".py", ".json", ".js"]


def main(args):
    from_char = args.from_char
    to_char = args.to_char
    # Walk the file tree
    for root, dirs, files in os.walk("."):
        for file in files:
            _, ext = os.path.splitext(file)
            if ext in ignores:
                continue
            filepath = os.path.join(root, file)
            if ".md" not in filepath:
                continue
            # Replace the filename in all the files
            # (can do this in the same walk, same logic)
            try:
                replace_char_in_link(filepath, from_char, to_char)
            except Exception:
                continue
            # Rename the file
            rename_file_replace_char(filepath, from_char, to_char)


def decompose(file):
    dir = os.path.dirname(file)
    base = os.path.basename(file)
    # Get extension
    stem, ext = os.path.splitext(base)
    return dir, base, stem, ext


def transform_url(
    content: str, from_char: str, to_char: str, original_file: str
) -> str:
    url_regex = re.compile(r"\[.*?\]\((.*?)\)")

    transform_result = content
    links = re.findall(url_regex, content)

    for link in links:
        link = relpath(original_file, link)
        path, filename = os.path.split(link)
        file_stem, ext = os.path.splitext(filename)
        new_filename = file_stem.replace(from_char, to_char) + ext
        new_link = os.path.join(path, new_filename)
        new_link = new_link.lower()
        transform_result = transform_result.replace(link, new_link)

    return transform_result


def relpath(note_editing: str, target_note: str) -> str:
    return os.path.relpath(
        path=target_note,
        start=os.path.dirname(os.path.abspath(note_editing)),
    )


def replace_char_in_link(file, from_char, to_char):
    if file.endswith(".md"):
        with open(file, "r") as f:
            content = f.read()

        with open(file, "w") as f:
            f.write(transform_url(content, from_char, to_char, file))


def cleanup_filename(file: str) -> str:
    file = file.replace(" ", "-")
    file = file.replace(".", "-")
    file = file.lower()
    return file


def rename_file_replace_char(file, from_char, to_char):
    dirname = os.path.dirname(os.path.abspath(file))
    os.makedirs(dirname, exist_ok=True)
    print("making directory", dirname)
    dir, base, stem, ext = decompose(file)
    new_stem = stem.replace(from_char, to_char)
    new_base = new_stem + ext
    new_path = os.path.join(dir, new_base)
    new_path = new_path.lower()
    if new_path != file:
        print(f"Renaming {file} to {new_path}")
        # Rename the file
        os.rename(file, new_path)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Replace characters in filenames and links"
    )

    parser.add_argument("--from-char", type=str, help="Character to replace")
    parser.add_argument("--to-char", type=str, help="Replacement character")
    parser.add_argument("--dir", type=str,
                        help="Directory containing note files")

    args = parser.parse_args()
    dir = args.dir
    os.chdir(dir)
    main(args)
