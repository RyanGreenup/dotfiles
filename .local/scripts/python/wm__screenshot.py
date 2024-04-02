#!/usr/bin/env python3
# Path: path/to/your_script.py
# -*- coding: utf-8 -*-

import os
import datetime
import subprocess
from subprocess import PIPE
from utils import get_display_server, DisplayServer

SCREENSHOT_DIR = "/tmp/screenshots/"


def main():
    print(screenshot(get_display_server()))


def screenshot_name() -> str:
    iso_time = datetime.datetime.now().isoformat()
    return os.path.join(SCREENSHOT_DIR, f"{iso_time}.png")


def screenshot(server: DisplayServer = DisplayServer.Wayland) -> str:
    match server:
        case DisplayServer.Wayland:
            return wayland_screenshot()
        case DisplayServer.X11:
            return x11_screenshot()
        case _:
            raise Exception("Only implemented for Wayland and X11")


def wayland_screenshot():
    out = subprocess.run(["slurp"], stdout=PIPE, text=True, check=True)
    dim = out.stdout.strip()
    name = screenshot_name()
    out = subprocess.run(["grim", "-g", dim, name])
    copy_image_to_clipboard(name, DisplayServer.Wayland)
    return name


def x11_screenshot():
    name = screenshot_name()
    subprocess.run(["maim", "-s", name])
    copy_image_to_clipboard(name, DisplayServer.X11)
    return name


def copy_image_to_clipboard(
    image: str, server: DisplayServer = DisplayServer.Wayland
) -> None:

    match server:
        case DisplayServer.Wayland:
            subprocess.run(["wl-copy", "-t", "image/png"],
                           stdin=open(image, "rb"))
        case DisplayServer.X11:
            subprocess.run(
                ["xclip", "-selection", "clipboard", "-t", "image/png"],
                stdin=open(image, "rb"),
            )
        case DisplayServer.Quartz:
            subprocess.run(["pngpaste", image])
        case _:
            print("Only implemented for Wayland, X11 and Quartz")


if __name__ == "__main__":
    main()
