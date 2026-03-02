#!/usr/bin/env python3
# Navigate to the next or previous workspace on the current output.
# Creates a new numbered workspace if none exists in that direction.
# Workspaces numbered 101+ are special and are never entered by this script.
#
# Usage: workspace-nav.py next|prev
#
# Relies on:
#   swaymsg -t get_workspaces   (swaymsg.1, sway-ipc.7)
#   workspace number <N>        (sway.5)

import json, subprocess, sys

SPECIAL_MIN = 101


def swaymsg(*args):
    return subprocess.run(["swaymsg"] + list(args), capture_output=True, text=True).stdout


if len(sys.argv) != 2 or sys.argv[1] not in ("next", "prev"):
    print("Usage: workspace-nav.py next|prev", file=sys.stderr)
    sys.exit(1)

direction = sys.argv[1]

workspaces = json.loads(swaymsg("-t", "get_workspaces"))
focused    = next((w for w in workspaces if w["focused"]), None)

if not focused:
    sys.exit(1)

current = focused["num"]
output  = focused["output"]

# No-op when on a special workspace — leave via its own toggle keybinding.
if current >= SPECIAL_MIN:
    sys.exit(0)

# Regular workspace numbers on this output, sorted
nums = sorted(
    w["num"] for w in workspaces
    if w["output"] == output and w["num"] < SPECIAL_MIN
)

if direction == "next":
    candidates = [n for n in nums if n > current]
    target = candidates[0] if candidates else current + 1
else:
    candidates = [n for n in nums if n < current]
    target = candidates[-1] if candidates else max(current - 1, 1)

# Clamp to regular range
target = min(target, SPECIAL_MIN - 1)
target = max(target, 1)

swaymsg(f"workspace number {target}")
