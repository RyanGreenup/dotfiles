#!/usr/bin/env python3


import os
import sys
from utils import sed_notes

if len(sys.argv) < 3:
    print("Moves a note file by renaming and running sed")
    print("Git commit before and after")
    print("Assumes notes are in a flat directory using dots for separators")
    print("Usage: python3 {} <path to file> <new path>".format(sys.argv[0]))
    sys.exit(1)


def main():
    note_old = sys.argv[1]
    note_new = sys.argv[2]

    # move note_old to note_new
    os.rename(note_old, note_new)

    # Rename each occurence of the old note name with the new one
    # This assumes flat files for simplicity sake
    sed_notes(os.path.basename(note_old), os.path.basename(note_new))


if __name__ == '__main__':
    # print(get_files("/home/ryan/Notes/slipbox"))
    main()
