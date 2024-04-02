#!/usr/bin/env python3
# Path: path/to/your_script.py
# -*- coding: utf-8 -*-

"""
Utilities for scripts that can be reusused

Mostly schedule visualization scripts.
"""

import os
import subprocess
import re
import sys

from enum import Enum

from config import Config
config = Config.default()
# An enum for keys

preview_cmd = "bat --color=always --style=snip {}"


class Key(Enum):
    UP = "Up"
    DOWN = "Down"
    LEFT = "Left"
    RIGHT = "Right"
    ENTER = "Enter"
    ESCAPE = "Escape"
    TAB = "Tab"
    BACKSPACE = "Backspace"
    SPACE = "Space"
    # F Keys
    F1 = "F1"
    F2 = "F2"
    F3 = "F3"
    F4 = "F4"
    F5 = "F5"
    F6 = "F6"
    F7 = "F7"
    F8 = "F8"
    F9 = "F9"
    F10 = "F10"
    F11 = "F11"
    F12 = "F12"
    # other keys
    INSERT = "Insert"
    DELETE = "Delete"
    HOME = "Home"
    END = "End"
    PAGE_UP = "Page Up"
    PAGE_DOWN = "Page Down"
    # Super
    SUPER = "Super"
    # Control
    CONTROL = "Control"
    # Alt
    ALT = "Alt"


keys = {
    13: Key.ENTER,
    27: Key.ESCAPE,
    9: Key.TAB,
    32: Key.SPACE,
    127: Key.BACKSPACE,
    65: Key.UP,
    66: Key.DOWN,
    67: Key.RIGHT,
    68: Key.LEFT,
    79: Key.F1,
    80: Key.F2,
    81: Key.F3,
    82: Key.F4,
    83: Key.F5,
    84: Key.F6,
    85: Key.F7,
    86: Key.F8,
    87: Key.F9,
    88: Key.F10,
    89: Key.F11,
    90: Key.F12
}


def getch_unix():
    os.system('stty raw -echo')
    char = sys.stdin.read(1)
    if ord(char) in keys:
        char = keys[ord(char)]

    os.system('stty -raw echo')
    return char


def check_valid_task(task: str) -> bool:
    """
    Checks if a task string is valid.
    """
    pattern = re.compile(r".*\d{1,2}:\d{2} - \d{1,2}:\d{2} .+")
    return bool(re.match(pattern, task))


def test_check_valid_task():
    assert check_valid_task(
        "10:30 - 11:00 Finalise Quartz and MD Book Workflow")
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


def path_to_title(path: str) -> str:
    """Convert a path into a corresponding title
    Example: "python.some-note-on-python.md" -> "Python / Some Note on Python"
    """
    path = os.path.basename(path)
    title = path.replace(".md", "")
    title = title.replace(".", " / ")
    title = title.replace("-", " ")
    return title.title()


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


def open_in_editor(files: list[str], editor=config.editor) -> None:
    subprocess.run([editor]+files, check=True)


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
                    full_path if not relative else os.path.relpath(
                        full_path, dir_path)
                )
                matching_notes.append(path)
    return matching_notes


def fzf_select(notes: list[str],
               preview: bool = False,
               chooser: str = "fzf",
               multi: bool = True) -> list[str]:
    """
    Use fzf to select a note from a list of notes
    """
    cmd = [chooser]
    if multi:
        cmd.append("-m")
    if preview:
        cmd.append("--preview")
        cmd.append(preview_cmd)
    out = subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        input="\n".join(notes),
        text=True, check=True)
    files = out.stdout.splitlines()
    return files


def gui_select(input: list[str],
               chooser: list[str] = ["rofi", "-dmenu"]) -> str:
    """
    Use a GUI chooser to select an item from a list
    """
    out = subprocess.run(
        chooser,
        stdout=subprocess.PIPE,
        input="\n".join(input),
        text=True, check=True)
    # Only one item is selected
    out = out.stdout.strip()
    return out


def sk_cmd(dir: str,
           preview: bool = False,
           chooser: str = "sk",
           multi: bool = True,
           relative: bool = True
           ) -> list[str]:
    old_dir = os.getcwd()
    os.chdir(dir)
    cmd = [chooser, "--ansi", "-i"]
    if multi:
        cmd.append("-m")
    interactive = 'rg -l "{}"'
    cmd += ["-c", interactive]
    if preview:
        cmd.append("--preview")
        cmd.append(preview_cmd)
    out = subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        text=True, check=True)
    files = out.stdout.splitlines()
    if relative:
        files = [os.path.abspath(f) for f in files]

    # Change back to original directory
    os.chdir(old_dir)
    return files


def check_for_binary(bin: str) -> bool:
    path_dirs = os.getenv("PATH")
    if not path_dirs:
        print("No PATH environment variable set", file=sys.stderr)
        return False
    for dir in path_dirs:
        if os.path.exists(f"{dir}/{bin}"):
            # check if the size is non-zero
            if os.path.getsize(f"{dir}/{bin}"):
                # Check if it's executable
                if os.access(f"{dir}/{bin}", os.X_OK):
                    return True
    return False
