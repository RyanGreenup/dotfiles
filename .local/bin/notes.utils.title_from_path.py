#!/usr/bin/env python3

import typer
import os


def main(path: str):
    """Converts a filepath to a markdown heading"""
    # Take the basename
    path = os.path.basename(path)
    # Drop the extensions
    path, _ = os.path.splitext(path)
    # Take the last heirarchical
    # path = path[::-1]
    _, path = os.path.splitext(path)
    path = path[1:]
    # path = path[::-1]
    # STDOUT
    print(path)


if __name__ == "__main__":
    typer.run(main)


