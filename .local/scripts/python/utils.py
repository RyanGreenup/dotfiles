#!/usr/bin/env python3
# Path: path/to/your_script.py
# -*- coding: utf-8 -*-

import sys
from enum import Enum
import os


class DisplayServer(Enum):
    Wayland = "wayland"
    X11 = "x11"
    Quartz = "quartz"
    Unknown = "unknown"


def get_display_server() -> DisplayServer:
    # Check for wayland
    if is_wayland():
        return DisplayServer.Wayland
    elif is_x11():
        return DisplayServer.X11
    elif is_quartz():
        return DisplayServer.Quartz
    else:
        print("Unknown Display Server")
        return DisplayServer.Unknown


def is_wayland() -> bool:
    return "wayland" in os.environ.get("XDG_SESSION_TYPE", "").lower()


def is_x11() -> bool:
    xdg = "x11" in os.environ.get("XDG_SESSION_TYPE", "").lower()
    wayland = is_wayland()
    display_var = "DISPLAY" in os.environ

    return xdg and not wayland and display_var


def is_quartz() -> bool:
    return sys.platform == "darwin"


class OSName(Enum):
    Arch = "arch"
    Debian = "debian"
    Suse = "suse"
    Fedora = "fedora"
    Gentoo = "gentoo"
    Void = "void"
    OpenSuse = "opensuse"
    Ubuntu = "ubuntu"
    Windows = "windows"
    Mac = "mac"
    FreeBSD = "freebsd"
    OpenBSD = "openbsd"
    Unknown = "unknown"


def get_os() -> OSName:

    os = OSName.Unknown
    # Check if it's windows
    if sys.platform == "win32":
        os = OSName.Windows
    # Check if it's Mac
    elif sys.platform == "darwin":
        os = OSName.Mac
    # Check if it's BSD
    elif sys.platform.startswith("freebsd"):
        os = OSName.FreeBSD
    elif sys.platform.startswith("openbsd"):
        os = OSName.OpenBSD
    elif sys.platform.startswith("linux"):
        with open('/etc/os-release') as f:
            for line in f:
                if line.startswith('ID='):
                    os_name = line.split('=')[1].strip()
                    match os_name:
                        case "arch":
                            os = OSName.Arch
                            break
                        case "debian":
                            os = OSName.Debian
                            break
                        case "fedora":
                            os = OSName.Fedora
                            break
                        case "gentoo":
                            os = OSName.Gentoo
                            break
                        case "void":
                            os = OSName.Void
                            break
                        case "suse":
                            os = OSName.Suse
                            break
                        case _:
                            os = OSName.Unknown
                    break
    else:
        os = OSName.Unknown

    return os
