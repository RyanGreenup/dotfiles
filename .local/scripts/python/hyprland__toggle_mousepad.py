#!/usr/bin/env python3
# Path: path/to/your_script.py
# -*- coding: utf-8 -*-
from enum import Enum
import sys

import json
import subprocess
from subprocess import PIPE
from rich.console import Console

# Create a Rich console object
console = Console()


def get_all_mice() -> list[str]:
    mice = []

    out = subprocess.run(["hyprctl", "devices", "-j"],
                         stdout=PIPE, text=True, check=True)

    out_dict = json.loads(out.stdout)
    if "mice" in out_dict:
        for mouse in out_dict["mice"]:
            if not isinstance(mouse, dict):
                print(f"Expected dict, got {type(mouse)}")
                continue
            else:
                name = mouse.get("name")
                if name is None or not isinstance(name, str):
                    continue
                if "touchpad" in name:
                    mice.append(name)
    return mice


def get_all_mouse_keyword() -> list[str]:
    mice = get_all_mice()
    if mice:
        return [make_keyword(m) for m in mice]
    else:
        return []


def make_keyword(mouse_name: str):
    return f"device:{mouse_name}:enabled"


def get_status() -> dict:
    status = {}
    for mouse in get_all_mice():
        mouse_keyword = make_keyword(mouse)
        out = subprocess.run(["hyprctl", "getoption", mouse_keyword, "-j"],
                             stdout=PIPE, text=True, check=True)
        try:
            out_dict = json.loads(out.stdout)
        except json.JSONDecodeError:
            print(f"Error: {out.stdout}", file=sys.stderr)
            continue
        except Exception as e:
            print(f"Error: {e}", file=sys.stderr)
            continue
        is_enabled = out_dict.get("int") > 0
        if is_enabled is None:
            continue
        else:
            status[mouse] = is_enabled
    return status


class ChangeCommand(Enum):
    ENABLED = 1
    DISABLED = 0
    TOGGLE = 2


def notify(message: str):
    subprocess.run(["notify-send", "-u", "normal", message])
    print(message)


def change_all_mouse(change: ChangeCommand):
    val = 1 if change else 0
    mice = get_all_mice()
    for mouse in mice:
        match change:
            case ChangeCommand.ENABLED:
                val = 1
            case ChangeCommand.DISABLED:
                val = 0
            case ChangeCommand.TOGGLE:
                mouse_status = get_status().get(mouse)
                if mouse_status is None:
                    print(f"Could not get status of {mouse} Leaving it alone")
                    continue
                else:
                    val = 1 if not mouse_status else 0
        mouse_keyword = make_keyword(mouse)
        out = subprocess.run(["hyprctl", "keyword", mouse_keyword, str(val)],
                             stdout=PIPE, text=True, check=False)
        if out.returncode != 0:
            notify(f"Error: {out.stdout}", file=sys.stderr)
        else:
            notify(f"DONE: {mouse} is {'enabled' if val else 'disabled'}")
        console.print(out.stdout)


def disable_all_mouse():
    change_all_mouse(ChangeCommand.DISABLED)


def enable_all_mouse():
    change_all_mouse(ChangeCommand.ENABLED)


if __name__ == "__main__":
    change_all_mouse(ChangeCommand.TOGGLE)


CITE = """
# This was adapted from
<https://www.reddit.com/r/hyprland/comments/11kr8bl/hotkey_disable_touchpad/>:



```sh
#!/bin/sh

# Set device to be toggled
HYPRLAND_DEVICE="pixa3854:00-093a:0274-touchpad"


HYPRLAND_VARIABLE="device:$HYPRLAND_DEVICE:enabled"

if [ -z "$XDG_RUNTIME_DIR" ]; then
  export XDG_RUNTIME_DIR=/run/user/$(id -u)
fi

# Check if device is currently enabled (1 = enabled, 0 = disabled)
DEVICE="$(hyprctl getoption $HYPRLAND_VARIABLE | grep 'int: 1')"

if [ -z "$DEVICE" ]; then
    # if the device is disabled, then enable
      notify-send -u normal "Enabling Touchpad"
    hyprctl keyword $HYPRLAND_VARIABLE true
else
    # if the device is enabled, then disable
    notify-send -u normal "Disabling Touchpad"
    hyprctl keyword $HYPRLAND_VARIABLE false
fi
```"""
