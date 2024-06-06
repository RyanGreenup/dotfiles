#!/usr/bin/env python3
import json
import subprocess


def get_sway_tree():
    result = subprocess.run(
        ["swaymsg", "-t", "get_tree"], capture_output=True, text=True
    )
    if result.returncode == 0:
        return json.loads(result.stdout)
    else:
        raise RuntimeError("swaymsg command failed")


def parse_windows(tree):
    def extract_windows(obj):
        if "app_id" in obj or "window_properties" in obj:
            win_id = obj.get("id")
            win_name = obj.get("name")
            win_type = obj.get("app_id") or obj.get("window_properties", {}).get(
                "class"
            )
            windows.append((win_id, win_name, win_type))
        for child in obj.get("nodes", []):
            extract_windows(child)

    windows = []
    extract_windows(tree)
    return windows


def show_rofi_menu(windows):
    rofi_input = "\n".join(
        [
            f'<span weight="bold">{win_type}</span> - {win_name}'
            for _, win_name, win_type in windows
        ]
    )
    result = subprocess.run(
        ["rofi", "-dmenu", "-markup-rows", "-i", "-p", "window", "-format", "i"],
        input=rofi_input,
        capture_output=True,
        text=True,
    )
    if result.returncode == 0 and result.stdout.strip().isdigit():
        return int(result.stdout.strip())
    else:
        return None


def focus_window(window_id):
    subprocess.run(["swaymsg", f"[con_id={window_id}]", "focus"])


def main():
    tree = get_sway_tree()
    windows = parse_windows(tree)
    selected_index = show_rofi_menu(windows)

    if selected_index is not None and selected_index < len(windows):
        focus_window(windows[selected_index][0])


if __name__ == "__main__":
    main()
