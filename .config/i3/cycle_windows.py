#!/usr/bin/env python3
# THis is a work in progress
import json
from subprocess import run, PIPE
import i3ipc
import sys


i3 = i3ipc.Connection()

workspace = i3.get_tree().find_focused().workspace()

if len(sys.argv) > 1:
    if sys.argv[1] == "prev":
        workspace = list(workspace)
        workspace = workspace[::-1]
        print("reverse")

found_focused = False
next_win_id = None
for window in workspace:
    if window.focused:
        found_focused = True
        print(window.name)
    elif found_focused:
        next_win_id = window.id
        print(f"{window.name}: {window.id}")

if next_win_id:
    print(next_win_id)
    i3.command(f"[con_id={next_win_id}] focus")


