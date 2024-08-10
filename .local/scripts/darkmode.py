#!/usr/bin/env python3
# ~/.local/scripts/darkmode.py

# Functions/sunrise_checker.py
import datetime
import os
from subprocess import run


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


def config(dark: bool = True):
    if dark:
        run( [ "gsettings", "set", "org.gnome.desktop.interface", "gtk-theme", "Adwaita-dark"])
        run( [ "gsettings", "set", "org.gnome.desktop.interface", "color-scheme", "prefer-dark"])
        # Export env var
        os.environ["QT_QPA_PLATFORMTHEME"] = "qt6ct"
    else:
        run(["gsettings", "reset", "org.gnome.desktop.interface", "gtk-theme"])
        run(["gsettings", "reset", "org.gnome.desktop.interface", "color-scheme"])
        run( [ "gsettings", "set", "org.gnome.desktop.interface", "color-scheme", "prefer-light"])
        # Export env var
        os.environ["QT_QPA_PLATFORMTHEME"] = ""


if __name__ == "__main__":
    config(is_dark_out())
