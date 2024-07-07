#!/usr/bin/env python3
import os
import subprocess
from pathlib import Path
import typer


NOTES_DIR = os.path.join(os.path.expanduser("~"), Path("Notes/slipbox"))


def make_link(file: Path) -> str:
    title = os.path.splitext(file)[0].replace("_", " / ").replace("-", " ").title()
    return f"[{title}]({file})"


def get_markdown_links(
    start_dir: Path = Path(os.getcwd()), notes_dir: Path = Path(NOTES_DIR)
):
    """
    Get relative markdown links starting from a given directory
    """
    # Change to directory to get relative `fd` output
    here = os.getcwd()
    os.chdir(notes_dir)
    ext = r"\.md$"

    # Get the files using fd
    cmd = f"fd {ext} | fzf -m --preview 'bat --color=always " + "{}'"
    files = (
        subprocess.run(cmd, shell=True, stdout=subprocess.PIPE)
        .stdout.decode("utf-8")
        .strip()
        .split("\n")
    )

    # Change back
    os.chdir(here)

    # Cast files to relative paths
    if not os.path.isdir(start_dir):
        start_dir = start_dir.parent

    files = [os.path.relpath(os.path.abspath(f), start_dir) for f in files]

    # Make into md links and drop empties
    [print(make_link(Path(f))) for f in files if f]


if __name__ == "__main__":
    typer.run(get_markdown_links)
