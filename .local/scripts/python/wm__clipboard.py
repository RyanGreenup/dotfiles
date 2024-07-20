#!/usr/bin/env python3
# /home/ryan/.local/scripts/python/wm__clipboard.py
# -*- coding: utf-8 -*-

"""
Wrapper for clipboard to make life easier
"""

import subprocess
from utils import get_display_server, DisplayServer
import sys
import argparse
from enum import Enum


class MimeType(Enum):
    TEXT = "text/plain"
    IMAGE = "image/png"
    HTML = "text/html"
    URI = "text/uri-list"
    FILE = "text/uri-list"
    NONE = None


class Command(Enum):
    COPY = "copy"
    PASTE = "paste"


def copy_to_clipboard(
    server: DisplayServer = DisplayServer.Wayland, mime: str | None = None
) -> None:
    """Copy to clipboard"""
    # get the stdinput
    input = sys.stdin.read()
    additional_args: list[str] = []
    if mime:
        additional_args = ["-t", mime]
    match server:
        case DisplayServer.Wayland:
            subprocess.run(
                ["wl-copy"] + additional_args, input=input, text=True, check=True
            )
        case DisplayServer.X11:
            subprocess.run(
                ["xclip", "-selection", "clipboard"] + additional_args,
                input=input,
                text=True,
                check=True,
            )
        case _:
            import pyperclip

            pyperclip.copy(sys.stdin.read())


def paste_from_clipboard(
    server: DisplayServer = DisplayServer.Wayland, mime: str | None = None
) -> None:
    """Paste to clipboard"""
    additional_args: list[str] = []
    if mime:
        additional_args = ["-t", mime]
    match server:
        case DisplayServer.Wayland:
            subprocess.run(["wl-paste"] + additional_args, text=True, check=True)
        case DisplayServer.X11:
            subprocess.run(
                ["xclip", "-selection", "clipboard", "-o"] + additional_args,
                text=True,
                check=True,
            )
        case _:
            import pyperclip

            print(pyperclip.paste())


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Script to perform copy and paste commands."
    )
    parser.add_argument(
        "command",
        type=str,
        choices=[Command.COPY.value, Command.PASTE.value],
        help="Command to be performed.",
    )
    parser.add_argument(
        "--type_mime",
        "-t",
        type=str,
        default=None,
        choices=[m.value for m in MimeType],
        help="MIME type.",
    )
    args = parser.parse_args()

    assert isinstance(args.command, str)

    if isinstance(args.type_mime, str):
        mime = args.type_mime
    else:
        mime = MimeType.NONE.value

    match args.command:
        case Command.COPY.value:
            copy_to_clipboard(get_display_server(), mime)
        case Command.PASTE.value:
            paste_from_clipboard(get_display_server(), mime)
        case _:
            print(f"Invalid command: {args.command}")

    # print(f"Main function called with MIME: {args.mime}")
