#!/usr/bin/env python3
import os
import typer
from pathlib import Path
import sys
from pprint import pprint


def main(old: Path, new: Path):
    if old.is_dir():
        sys.exit("Directories not handled (yet)")
    old_file = old

    # Check if the new path is a directory
    if new.is_dir():
        new_file = new / old.name
    else:
        new_file = new

    move(old_file, new_file)


def get_all_files(directory: Path) -> list[str]:
    files = [
        [os.path.join(root, file) for file in files]
        for root, _, files in os.walk(directory)
    ]
    # Flatten the list
    files = [file for sublist in files for file in sublist]
    return files


def move(old_file: Path, new_file: Path):
    # Get all the files
    all_files = get_all_files(Path("."))
    all_notes = [s for s in all_files if s.endswith(".md")]

    print(all_notes)

    # Get the relative paths to change for each file
    links_map = {
        s: {
            "old": os.path.relpath(old_file, os.path.dirname(s)),
            "new": os.path.relpath(new_file, os.path.dirname(s)),
            "old_abs": os.path.relpath(old_file, "."),
            "new_abs": os.path.relpath(new_file, "."),
        }
        for s in all_notes
    }

    # Loop over the files
    for note_file, d in links_map.items():

        # Pull out the links
        old_link = d["old"]
        new_link = d["new"]
        old_link_abs = d["old_abs"]
        new_link_abs = d["new_abs"]

        # Replace the links
        with open(note_file, "r") as f:
            content = f.read()
        content = content.replace(old_link, new_link).replace(
            old_link_abs, new_link_abs
        )

        # Update the file
        with open(note_file, "w") as f:
            f.write(content)

    # Update the links within the file
    target_links_map = {
        os.path.relpath(note, os.path.dirname(old_file)): os.path.relpath(note, os.path.dirname(new_file))
        for note in all_files
    }

    assert len(target_links_map) == len(all_files), "A note was incorrectly dropped or added"

    pprint(target_links_map)


    with open(old_file, 'r') as file:
        lines = file.readlines()

    # Open the new file in write mode, or the same file if overwriting
    with open(old_file, 'w') as file:
        for line in lines:
            # Replace each line's content based on the dictionary mappings
            for old_link, new_link in target_links_map.items():
                if old_link in line:
                    line = line.replace(old_link, new_link)
                    break
            # Write the updated line
            file.write(line)


    # Move the file
    old_file.rename(new_file)

    # Print the result
    print(f"Moved {old_file} to {new_file}")



if __name__ == "__main__":
    typer.run(main)
