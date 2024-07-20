#!/usr/bin/env python3
import os
import subprocess
from pathlib import Path
import typer
from enum import Enum
import tempfile
import sys


# Make a tempfile


NOTES_DIR = os.path.join(os.path.expanduser("~"), Path("Notes/slipbox"))


class OutputType(Enum):
    tmp = "tmp"
    stdout = "stdout"


def make_link(file: Path) -> str:
    title = os.path.splitext(file)[0].replace("_", " / ").replace("-", " ").title()
    return f"[{title}]({file})"


def get_markdown_links(
    start_dir: Path = Path(os.getcwd()),
    notes_dir: Path = Path(NOTES_DIR),
    output_type: OutputType = typer.Option(
        OutputType.stdout.value, help=("The output type")
    ),
    output_file: Path = typer.Option(
        None, help="The output file, overrides output_type."
    ),
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
    try:
        files = (
            subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, check=True)
            .stdout.decode("utf-8")
            .strip()
            .split("\n")
        )
    except subprocess.CalledProcessError as e:
        print(e, file=sys.stderr)
        return

    # Remove empties
    files = [f for f in files if f]
    # If it's empty, return
    if not files:
        return

    # Change back
    os.chdir(here)

    # Check that start dir is a directory
    if not os.path.isdir(start_dir):
        start_dir = start_dir.parent

    # Get relative paths
    files = [os.path.relpath(os.path.abspath(f), start_dir) for f in files]

    links = [make_link(Path(f)) for f in files if f]

    if len(links) > 1:
        # Sort links in alphabetical order
        links.sort()
        # Make list items
        links = [f"- {link}" for link in links]

    if output_file:
        with open(output_file, "w") as f:
            [f.write(f"{link}\n") for link in links]
    else:
        match output_type:
            case OutputType.tmp:
                with tempfile.NamedTemporaryFile(delete=False) as tmp:
                    [tmp.write(f"{link}\n".encode("utf-8")) for link in links]
                    print(tmp.name)
            case OutputType.stdout:
                [print(link) for link in links]


if __name__ == "__main__":
    typer.run(get_markdown_links)
