#!/usr/bin/env python3
# Path: path/to/your_script.py
# -*- coding: utf-8 -*-

"""
Utilities for scripts that can be reusused

Mostly schedule visualization scripts.
"""

import os
import re
import sys


def check_valid_task(task: str) -> bool:
    """
    Checks if a task string is valid.
    """
    pattern = re.compile(r".*\d{1,2}:\d{2} - \d{1,2}:\d{2} .+")
    return bool(re.match(pattern, task))


def test_check_valid_task():
    assert check_valid_task("10:30 - 11:00 Finalise Quartz and MD Book Workflow")
    assert not check_valid_task("10:30 - 11:00")
    assert not check_valid_task("Finalise Quartz and MD Book Workflow")


test_check_valid_task()


def extract_times(task: str) -> tuple[str, str, str] | None:
    """
    Extracts the start and end times from a task string.
    """
    pattern = re.compile(r".*(\d{2}:\d{2}) - (\d{1,2}:\d{2}) (.+)")
    match = re.findall(pattern, task)
    try:
        start_time, end_time, description = match[0]
    except IndexError:
        print(f"Task {task} is not valid", file=sys.stderr)
        return None
    return start_time, end_time, description


def test_extract_times():
    task = "- [ ] 12:00 - 12:30 Write Note Dispatcher Screen (Py/Fish)"
    assert extract_times(task) == (
        "12:00",
        "12:30",
        "Write Note Dispatcher Screen (Py/Fish)",
    )


test_extract_times()


def title_to_path(title: str) -> str:
    """Convert a title into a corresponding path
    Example: "Python / Some Note on Python" -> "python.some-note-on-python.md"
    """
    title = title.lower()
    title = title.replace(" ", "-")
    title = title.replace(" / ", ".")
    title = title.replace("/", ".")
    return title + ".md"


def create_md_link(title: str, path: str) -> str:
    """Create a markdown link with title and path"""
    return f"[{title}]({path})"


def heirarchical_join(*args):
    """
    Join a list of strings in a heirarchical way

    This exists to enable moving between flat and heirarchical easily
    """
    # return "/".join(args)
    return ".".join(args)


def get_notes_dir() -> str:
    """Return the directory of the notes, in a function to promote portability"""
    HOME = os.getenv("HOME")
    assert HOME, "HOME not set"
    return f"{HOME}/Notes/slipbox"


def sed_notes(old: str, new: str):
    """
    Replace a string in all notes files

    The notes directory is taken from `get_notes_dir()` and the files
    are returned by `get_files()`
    """
    for file in get_files(get_notes_dir()):
        try:
            with open(file, "r") as f:
                text = f.read()
            if old in text:
                text = text.replace(old, new, -1)
                with open(file, "w") as f:
                    f.write(text)
        except Exception as e:
            print(e, file=sys.stderr)
            continue


def get_files(dir_path: str, relative: bool = False) -> list[str]:
    matching_notes = []
    for root, dirs, files in os.walk(dir_path):
        allowed_extensions = [".md", ".org", ".txt"]
        for file in files:
            stem, ext = os.path.splitext(os.path.basename(file))
            _ = stem
            if ext in allowed_extensions:
                full_path = f"{root}/{file}"
                path = (
                    full_path if not relative else os.path.relpath(full_path, dir_path)
                )
                matching_notes.append(path)
    return matching_notes
