#!/usr/bin/env python3

import argparse
import json
from subprocess import run, PIPE

from enum import Enum


class Action(Enum):
    MOVE = "move"
    FOCUS = "focus"


def move_container_to_workspace(workspace: str):
    run(["i3-msg", "--", "move", "container", "to", "workspace", workspace])


def focus_workspace(workspace: str):
    run(["i3-msg", "--", "workspace", "--no-auto-back-and-forth", workspace])


def main(action: str):
    # Get the current workspace
    out = run(["i3-msg", "-t", "get_workspaces"], stdout=PIPE, text=True)
    config = json.loads(out.stdout)
    current_workspace = None
    for e in config:
        if e["focused"]:
            current_workspace = e["name"]

    assert isinstance(current_workspace, str), "No current workspace found"

    # Get the other monitor
    out = run(["i3-msg", "-t", "get_outputs"], stdout=PIPE, text=True)
    # Parse the Dict
    config = json.loads(out.stdout)

    # First output is xroot so [1:]
    # Go over each monitor
    for e in config[1:]:
        candidate_workspace = e["current_workspace"]
        if candidate_workspace != current_workspace:
            match a:
                case Action.MOVE:
                    # Move the container
                    move_container_to_workspace(candidate_workspace)
                    # Also Focus
                    focus_workspace(candidate_workspace)
                case Action.FOCUS:
                    focus_workspace(candidate_workspace)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="i3 config script.")

    # Add arguments
    parser.add_argument(
        "action",
        type=str,
        choices=["move", "focus"],
        help='choose between "move" and "focus"',
    )

    # Parse arguments
    args = parser.parse_args()

    a = Action(args.action.lower())

    main(a.value)
