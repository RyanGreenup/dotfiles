#!/usr/bin/env python3
# Toggle a named special workspace (101+).
#
# Behaviour by current workspace:
#   regular (<101)          — record it, move any criteria-matched windows to
#                             target, jump to target (launch if workspace empty)
#   target workspace        — jump back to last recorded regular workspace
#   other special (>=101)   — move criteria-matched windows to target, jump
#
# --move-criteria handles windows that already exist on other workspaces
# (for_window only fires for newly created windows).
#
# Usage:
#   workspace-toggle.py NUMBER NAME [--launch CMD] [--move-criteria CRITERIA]
#
# Examples:
#   workspace-toggle.py 101 notes
#   workspace-toggle.py 102 signal \
#       --launch ~/.config/swayfx/scripts/open-messages.sh \
#       --move-criteria 'app_id="signal"'

import json, os, subprocess
from typing import Optional
import typer

SPECIAL_MIN = 101
STATE_FILE  = "/tmp/sway-last-regular-workspace"

app = typer.Typer(add_completion=False)


def swaymsg(*args: str) -> str:
    return subprocess.run(["swaymsg"] + list(args), capture_output=True, text=True).stdout


def get_workspaces() -> list:
    return json.loads(swaymsg("-t", "get_workspaces"))


@app.command()
def toggle(
    number:        int           = typer.Argument(..., help="Workspace number (>= 101)"),
    name:          str           = typer.Argument(..., help="Workspace name"),
    launch:        Optional[str] = typer.Option(None, help="Shell command to run if workspace has no windows"),
    move_criteria: Optional[str] = typer.Option(None, help="Move windows matching these sway criteria to the target workspace"),
):
    """Toggle a named special workspace."""
    target = f"{number}:{name}"

    workspaces = get_workspaces()
    focused    = next((w for w in workspaces if w["focused"]), None)

    if not focused:
        raise typer.Exit(1)

    num = focused.get("num", -1)

    if num == number:
        # Already on target — jump back to last regular workspace
        saved = open(STATE_FILE).read().strip() if os.path.exists(STATE_FILE) else ""
        swaymsg(f"workspace {saved or '1'}")

    else:
        # Navigating TO target
        if move_criteria:
            # Relocate any already-open matching windows, then re-query
            # so target_exists reflects whether the move populated the workspace
            swaymsg(f"[{move_criteria}] move to workspace {target}")
            workspaces = get_workspaces()

        target_exists = any(w["num"] == number for w in workspaces)

        if num < SPECIAL_MIN:
            open(STATE_FILE, "w").write(focused["name"])

        swaymsg(f"workspace {target}")

        if launch and not target_exists:
            subprocess.Popen(launch, shell=True)


if __name__ == "__main__":
    app()
