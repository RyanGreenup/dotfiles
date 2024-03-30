#!/usr/bin/env python3
# Path: path/to/your_script.py
# -*- coding: utf-8 -*-

"""
A Script to run fzf on a directory and open the selected file in nvim
"""

from utils import get_notes_dir
from subprocess import PIPE
import subprocess
import os
import sys
import click


@click.command()
@click.option(
    "--editor", default="Neovide.AppImage", help="The editor to open the file in"
)
@click.option(
    "--notes_dir",
    default=None,
    help=(
        "The directory to search for notes, defaults to a"
        " predefined directory in "
        "~/.local/bin/utils.py: get_notes_dir()"
    ),
)
def notes_find_fzf(editor: str = "Neovide.AppImage", notes_dir: str | None = None):
    if not notes_dir:
        notes_dir = get_notes_dir()
    original_dir = os.getcwd()
    os.chdir(notes_dir)  # [fn_chdir]

    # Find the Notes
    pattern = ["org", "md", "txt"]
    pattern = [r"\." + p + "$" for p in pattern]
    pattern = "|".join(pattern)
    cmd = f"fd -t f '{pattern}' {notes_dir}"
    files = sh(cmd)

    # Sort out by date
    files.sort(key=lambda x: os.path.getmtime(x), reverse=False)

    # Make relative to notes_dir
    files = [os.path.relpath(f, notes_dir) for f in files]

    # Let the user choose some with fzf
    fzf_cmd = "fzf -m"
    preview = "bat --color=always {}"
    preview = f"--preview '{preview}'"
    bind = "ctrl-f:interactive,pgup:preview-page-up,pgdn:preview-page-down"
    bind = "--bind '{bind}'"
    cmd = 'rg -l -t markdown -t org -t txt --ignore-case "{}"'
    cmd = f"-c '{cmd}'"
    fzf_cmd = f"sk --ansi -m {preview} {bind}"
    files = sh(fzf_cmd, input="\n".join(files))

    # Get the abs path
    files = [os.path.join(notes_dir, f) for f in files]

    # Open it
    subprocess.run([editor, *files])

    os.chdir(original_dir)


def sh(cmd: str, input: str | None = None) -> list[str]:
    if input:
        out = subprocess.run(
            cmd, shell=True, check=True, stdout=PIPE, text=True, input=input
        )
    else:
        out = subprocess.run(cmd, shell=True, check=True, stdout=PIPE, text=True)
    stdout = out.stdout.strip().splitlines()

    return stdout


if __name__ == "__main__":
    notes_find_fzf()

sys.exit(0)


# [fn_chdir]: It is necessary to change the directory to the notes directory
# because the fzf command will display the full path of the files. This is not
# desirable because it makes the output harder to read. By changing the
# directory to the notes directory, the relative path of the files can be
# displayed instead. This makes the output easier to read and understand.
