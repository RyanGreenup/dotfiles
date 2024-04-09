#!/usr/bin/env python3
"""
Module Docstring
================

This script lists all files in the current directory, writes them to a temporary file, copies this
file, opens the new file, and renames any changes made to file names.

"""

import os
import shutil

TEMP_OLD = "/tmp/old"
TEMP_NEW = "/tmp/new"


def list_files_to_temp(temp_file):
    """
    Lists all files in a directory and writes them to a temporary file.
    """
    files = os.listdir()
    with open(temp_file, 'w') as file:
        for single_file in files:
            file.write(f"{single_file}\n")


def copy_file(src, dest):
    """
    Copies a file from the source path to the destination path.
    """
    shutil.copyfile(src, dest)


def read_file_to_list(temp_file):
    """
    Reads a temporary file back into a list.
    """
    with open(temp_file, 'r') as file:
        return file.read().splitlines()


def rename_files(old_files, new_files, do_eval):
    """
    Compares each file in old and new lists, renames the file if filenames are not same.
    """
    renamed_files = list(zip(old_files, new_files))
    for old, new in renamed_files:
        if old != new:
            try:
                print(f"  {old} --> {new}", end='')
                if do_eval:
                    os.rename(old, new)
            except OSError:
                    print(f"...[FAIL]")
            else:
                    print(f"...[DONE]")
        else:
            print("")

    if not do_eval:
        print("--------------------------------")
        print("The above will be renamed, press enter to continue (or C-c to cancel)")
        input()


def main():
    list_files_to_temp(TEMP_OLD)
    copy_file(TEMP_OLD, TEMP_NEW)
    os.system(f"nvim {TEMP_NEW}")
    old_files = read_file_to_list(TEMP_OLD)
    new_files = read_file_to_list(TEMP_NEW)

    rename_files(old_files, new_files, False)
    rename_files(old_files, new_files, True)


if __name__ == '__main__':
    main()
