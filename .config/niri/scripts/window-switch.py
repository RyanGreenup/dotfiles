#!/usr/bin/env python3
# Window switcher: lists all open windows via swaymsg and focuses the chosen one via rofi.
# https://gist.github.com/lbonn/89d064cde963cfbacabd77e0d3801398
import json
import subprocess
import sys


def collect_windows(node, windows):
    if isinstance(node, dict):
        if "app_id" in node:
            windows.append({
                "id": node["id"],
                "name": node.get("name", ""),
                "app_id": node.get("app_id") or node.get("window_properties", {}).get("class", ""),
            })
        for child in node.get("nodes", []) + node.get("floating_nodes", []):
            collect_windows(child, windows)


def main():
    tree = json.loads(subprocess.check_output(["swaymsg", "-t", "get_tree"]))

    windows = []
    collect_windows(tree, windows)

    if not windows:
        sys.exit(0)

    lines = '\n'.join(
        f'<span weight="bold">{w["app_id"]}</span> - {w["name"]}'
        for w in windows
    )

    result = subprocess.run(
        ["rofi", "-dmenu", "-markup-rows", "-i", "-p", "window", "-format", "i"],
        input=lines,
        capture_output=True,
        text=True,
    )

    if result.returncode != 0 or not result.stdout.strip():
        sys.exit(0)

    con_id = windows[int(result.stdout.strip())]["id"]
    subprocess.run(["swaymsg", f"[con_id={con_id}] focus"])


if __name__ == "__main__":
    main()
