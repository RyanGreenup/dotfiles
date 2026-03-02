#!/usr/bin/env python3
import json
import subprocess
import sys

def niri_msg(cmd_list):
    res = subprocess.run(["niri", "msg", "-j"] + cmd_list, capture_output=True, text=True)
    return json.loads(res.stdout) if res.stdout else None

def toggle_scratchpad(app_id, launch_cmd):
    windows = niri_msg(["windows"]) or []
    workspaces = niri_msg(["workspaces"]) or []

    target = next((w for w in windows if w.get("app_id") == app_id), None)
    active_ws = next((w for w in workspaces if w.get("is_focused")), None)

    if not target or not active_ws:
        # NOT RUNNING -> Start it
        if not target:
            subprocess.Popen(launch_cmd, shell=True)
        return

    win_id = str(target["id"])

    # RUNNING AND FOCUSED -> Move to hidden scratchpad workspace, but DON'T follow it.
    if target.get("workspace_id") == active_ws.get("id") and target.get("is_focused"):
        subprocess.run([
            "niri", "msg", "action", "move-window-to-workspace",
            "scratchpad",
            "--window-id", win_id,
            "--focus=false",   # <-- key fix: stay on current workspace
        ])
    else:
        # RUNNING BUT NOT FOCUSED -> Bring to current workspace and focus
        subprocess.run([
            "niri", "msg", "action", "move-window-to-workspace",
            str(active_ws["idx"]),
            "--window-id", win_id,
        ])
        subprocess.run(["niri", "msg", "action", "focus-window", "--id", win_id])

if __name__ == "__main__":
    if len(sys.argv) < 3:
        sys.exit(1)
    toggle_scratchpad(sys.argv[1], sys.argv[2])
