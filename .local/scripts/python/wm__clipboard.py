#!/usr/bin/env python3
# Path: path/to/your_script.py
# -*- coding: utf-8 -*-

"""
Wrapper for clipboard to make life easier
"""


import subprocess
from subprocess import PIPE
from utils import get_display_server, DisplayServer
import sys
import argparse
import pyperclip


def main(copy: bool = False):
    """If copy is false, then this pastes"""
    if copy:
        copy_to_clipboard(get_display_server())
    else:
        paste_from_clipboard(get_display_server())


def copy_to_clipboard(server: DisplayServer = DisplayServer.Wayland) -> None:
    """Copy to clipboard"""
    match server:
        case DisplayServer.Wayland:
            subprocess.run(["wl-copy"], stdin=PIPE, text=True)
        case DisplayServer.X11:
            subprocess.run(["xclip", "-selection", "clipboard"], stdin=PIPE, text=True)
        case _:
            pyperclip.copy(sys.stdin.read())


def paste_from_clipboard(server: DisplayServer = DisplayServer.Wayland) -> None:
    """Paste to clipboard"""
    match server:
        case DisplayServer.Wayland:
            subprocess.run(["wl-paste"], text=True)
        case DisplayServer.X11:
            subprocess.run(["xclip", "-selection", "clipboard", "-o"], text=True)
        case _:
            print(pyperclip.paste())


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Add a description for your program")

    sub_parser = parser.add_subparsers(dest="command")
    copy_parser = sub_parser.add_parser("copy")
    paste_parser = sub_parser.add_parser("paste")

    args = parser.parse_args()

    match args.command:
        case "copy":
            copy_to_clipboard(get_display_server())
        case "paste":
            paste_from_clipboard(get_display_server())
        case _:
            main()