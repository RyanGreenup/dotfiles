#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "typer",
# ]
# ///
"""Hyprland-style scratchpads for niri.

Toggle named workspaces in/out with auto-launch, return-to-origin tracking,
and workspace navigation that skips scratchpad workspaces.
"""

import json
import subprocess
from enum import Enum
from pathlib import Path

import typer

SCRATCH_PREFIX = "scratch:"
STATE_FILE = Path.home() / ".cache" / "niri-scratchpad-state.json"
CONFIG_FILE = Path.home() / ".config" / "niri" / "scratchpads.json"

app = typer.Typer(help="Hyprland-style scratchpads for niri.")


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def load_config() -> dict:
    try:
        return json.loads(CONFIG_FILE.read_text())
    except FileNotFoundError:
        typer.echo(f"error: config not found at {CONFIG_FILE}", err=True)
        raise typer.Exit(1)


def load_state() -> dict:
    try:
        return json.loads(STATE_FILE.read_text())
    except (FileNotFoundError, json.JSONDecodeError):
        return {"return_to_id": None}


def save_state(state: dict) -> None:
    STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
    STATE_FILE.write_text(json.dumps(state))


def niri_json(command: str) -> list | dict | None:
    result = subprocess.run(
        ["niri", "msg", "--json", *command.split()],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        typer.echo(f"niri msg error: {result.stderr.strip()}", err=True)
        return None
    return json.loads(result.stdout)


def niri_action(args: list[str]) -> None:
    # Now captures and prints errors if Niri rejects the command
    result = subprocess.run(["niri", "msg", "action", *args], capture_output=True, text=True)
    if result.returncode != 0:
        typer.echo(f"niri action error: {result.stderr.strip()}", err=True)


def get_workspaces() -> list[dict]:
    return niri_json("workspaces") or []


def get_focused_workspace(workspaces: list[dict] | None = None) -> dict | None:
    if workspaces is None:
        workspaces = get_workspaces()
    for ws in workspaces:
        if ws.get("is_focused"):
            return ws
    return None


def get_windows() -> list[dict]:
    return niri_json("windows") or []


def is_scratchpad(ws: dict) -> bool:
    return (ws.get("name") or "").startswith(SCRATCH_PREFIX)


def scratch_ws_name(name: str) -> str:
    return f"{SCRATCH_PREFIX}{name}"


def find_app_window(app_id: str) -> dict | None:
    for w in get_windows():
        if w.get("app_id") == app_id:
            return w
    return None


def ensure_app_running(entry: dict) -> None:
    app_id = entry.get("app_id")
    if app_id and find_app_window(app_id):
        return
    command = entry.get("command", [])
    if not command:
        return
    subprocess.Popen(
        command,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        start_new_session=True,
    )


def jump_to_id(target_id: int, workspaces: list[dict] | None = None) -> None:
    """Safely translates an immutable ID back to a Niri-friendly index or name."""
    if workspaces is None:
        workspaces = get_workspaces()

    target_ws = next((w for w in workspaces if w["id"] == target_id), None)

    if target_ws:
        # Use the name if it has one, otherwise use the visual index
        ref = target_ws["name"] if target_ws.get("name") else str(target_ws["idx"])
        niri_action(["focus-workspace", ref])
    else:
        # Fallback in case the workspace was deleted
        niri_action(["focus-workspace-down"])


def _hide() -> None:
    """Internal hide: return from scratchpad to previous workspace."""
    state = load_state()
    workspaces = get_workspaces()
    focused = get_focused_workspace(workspaces)

    if not focused or not is_scratchpad(focused):
        return

    return_to_id = state.get("return_to_id")
    if return_to_id is not None:
        jump_to_id(return_to_id, workspaces)
    else:
        niri_action(["focus-workspace-down"])

    state["return_to_id"] = None
    save_state(state)


# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------


@app.command()
def toggle(name: str) -> None:
    config = load_config()
    if name not in config:
        typer.echo(f"error: scratchpad '{name}' not in config", err=True)
        raise typer.Exit(1)

    entry = config[name]
    ws_name = scratch_ws_name(name)
    state = load_state()
    workspaces = get_workspaces()
    focused = get_focused_workspace(workspaces)

    if not focused:
        return

    focused_name = focused.get("name") or ""

    # Already on this scratchpad → hide (return to previous)
    if focused_name == ws_name:
        return_to_id = state.get("return_to_id")
        if return_to_id is not None:
            jump_to_id(return_to_id, workspaces)
        else:
            niri_action(["focus-workspace-down"])

        state["return_to_id"] = None
        save_state(state)
        return

    # We're elsewhere → show this scratchpad
    if not is_scratchpad(focused):
        state["return_to_id"] = focused["id"]

    save_state(state)
    ensure_app_running(entry)
    niri_action(["focus-workspace", ws_name])


@app.command()
def show(name: str) -> None:
    """Show a scratchpad without toggle-off."""
    config = load_config()
    if name not in config:
        typer.echo(f"error: scratchpad '{name}' not in config", err=True)
        raise typer.Exit(1)

    entry = config[name]
    ws_name = scratch_ws_name(name)
    state = load_state()
    focused = get_focused_workspace()

    if not focused:
        return

    focused_name = focused.get("name") or ""
    if focused_name == ws_name:
        return

    if not is_scratchpad(focused):
        state["return_to_id"] = focused["id"]
        save_state(state)

    ensure_app_running(entry)
    niri_action(["focus-workspace", ws_name])


@app.command()
def hide() -> None:
    """Hide current scratchpad (return to previous workspace)."""
    _hide()


class Direction(str, Enum):
    up = "up"
    down = "down"


@app.command()
def nav(direction: Direction) -> None:
    """Navigate workspaces up/down, skipping scratchpad workspaces."""
    workspaces = get_workspaces()
    focused = get_focused_workspace(workspaces)
    if not focused:
        return

    if is_scratchpad(focused):
        _hide()
        return

    output = focused.get("output")
    regular = sorted(
        [
            ws
            for ws in workspaces
            if ws.get("output") == output and not is_scratchpad(ws)
        ],
        key=lambda ws: ws["idx"],
    )

    if not regular:
        return

    current_pos = None
    for i, ws in enumerate(regular):
        if ws["id"] == focused["id"]:
            current_pos = i
            break

    if current_pos is None:
        return

    target_pos = current_pos + (1 if direction == Direction.down else -1)
    if target_pos < 0 or target_pos >= len(regular):
        return

    target = regular[target_pos]

    # Translate the target ID back to a valid Niri reference
    ref = target["name"] if target.get("name") else str(target["idx"])
    niri_action(["focus-workspace", ref])


if __name__ == "__main__":
    app()
