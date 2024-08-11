#!/usr/bin/env python3
# ~/.local/scripts/darkmode.py

# Functions/sunrise_checker.py
from enum import Enum
import sys
import typer
import datetime
import os
from subprocess import run
import shutil


HOME = os.path.expanduser("~")

sunset_map = {
    1: datetime.datetime.now().replace(hour=20, minute=10, second=0),
    2: datetime.datetime.now().replace(hour=20, minute=0, second=0),
    3: datetime.datetime.now().replace(hour=19, minute=30, second=0),
    4: datetime.datetime.now().replace(hour=16, minute=50, second=0),
    5: datetime.datetime.now().replace(hour=17, minute=0, second=0),
    6: datetime.datetime.now().replace(hour=16, minute=50, second=0),
    7: datetime.datetime.now().replace(hour=17, minute=0, second=0),
    8: datetime.datetime.now().replace(hour=17, minute=20, second=0),
    9: datetime.datetime.now().replace(hour=17, minute=50, second=0),
    10: datetime.datetime.now().replace(hour=19, minute=0, second=0),
    11: datetime.datetime.now().replace(hour=19, minute=30, second=0),
    12: datetime.datetime.now().replace(hour=20, minute=0, second=0),
}


# Functions/time_checker.py
def is_dark_out():
    # Get sunset time
    current_time = datetime.datetime.now()
    sunset_time = sunset_map[current_time.month]

    # Check if current time is after 5 PM
    if current_time > sunset_time:
        return True
    else:
        return False


def toggle_kitty(dark: bool = True):
    kitty_conf_dir = os.path.join(HOME, ".config/kitty")
    dark_theme = os.path.join(kitty_conf_dir, "themes/catppuccin_macchiato.conf")
    light_theme = os.path.join(kitty_conf_dir, "themes/catppuccin_latte.conf")
    target_theme = os.path.join(kitty_conf_dir, "theme.conf")

    def set_theme(theme: str):
        shutil.copy(theme, target_theme)

    if dark:
        set_theme(dark_theme)
    else:
        set_theme(light_theme)


def config(dark: bool = True):
    toggle_kitty(dark)
    sys_config(dark)


def sys_config(dark: bool = True):
    if dark:
        run(
            [
                "gsettings",
                "set",
                "org.gnome.desktop.interface",
                "gtk-theme",
                "Adwaita-dark",
            ]
        )
        run(
            [
                "gsettings",
                "set",
                "org.gnome.desktop.interface",
                "color-scheme",
                "prefer-dark",
            ]
        )
        # Export env var
        os.environ["QT_QPA_PLATFORMTHEME"] = "qt6ct"
        # Copy
        os.copy_file_range
    else:
        print("D")
        run(["gsettings", "reset", "org.gnome.desktop.interface", "gtk-theme"])
        run(["gsettings", "reset", "org.gnome.desktop.interface", "color-scheme"])
        run(
            [
                "gsettings",
                "set",
                "org.gnome.desktop.interface",
                "color-scheme",
                "prefer-light",
            ]
        )
        # Export env var
        os.environ["QT_QPA_PLATFORMTHEME"] = ""


class Mode(Enum):
    LIGHT = "l"
    DARK = "d"
    AUTO = "a"


def main(mode: Mode = Mode.AUTO.value):
    """
    Toggle dark mode. Give first argument as l / d respectively otherwise
    interpreted based on time of year.
    """
    match mode:
        case Mode.AUTO:
            config(is_dark_out())
        case Mode.LIGHT:
            config(False)
        case Mode.DARK:
            config(True)


if __name__ == "__main__":
    typer.run(main)
