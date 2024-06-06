#!/usr/bin/env python3
# Path:  /home/ryan/.local/scripts/python/os__update.py
# -*- coding: utf-8 -*-

"""
Update The System
"""

from enum import Enum
from utils import OSName, get_os
import sys
import subprocess


def update_system() -> None:
    match get_os():
        case OSName.Arch:
            print("Updating Arch")
            subprocess.run(["sudo", "pacman", "-Syu"], check=True)
        case OSName.Ubuntu:
            print("Updating Ubuntu")
            subprocess.run(["sudo", "apt", "update"], check=True)
            subprocess.run(["sudo", "apt", "upgrade"], check=True)
        case OSName.Fedora:
            print("Updating Fedora")
            subprocess.run(["sudo", "dnf", "upgrade"], check=True)
        case OSName.Debian:
            print("Updating Debian")
            subprocess.run(["sudo", "apt", "update"], check=True)
            subprocess.run(["sudo", "apt", "upgrade"], check=True)
        case OSName.OpenSuse:
            print("Updating OpenSuse")
            subprocess.run(["sudo", "zypper", "update"], check=True)
        case OSName.Gentoo:
            print("Updating Gentoo")
            try:
                subprocess.run(
                    ["sudo", "emaint", "--auto", "sync"], check=True)
            except Exception:
                # TODO Pull other repositories
                subprocess.run(["sudo", "emerge", "--sync"], check=True)
            # With binaries
            # subprocess.run(["sudo", "emerge", "-guND", "@world"], check=True)
            # Witout Binaries
            subprocess.run(["sudo", "emerge", "-uND", "@world"], check=True)
        case OSName.Gentoo:
            print("Updating Void")
            subprocess.run(["sudo", "xbps", "-Syu"], check=True)


if __name__ == '__main__':
    update_system()
