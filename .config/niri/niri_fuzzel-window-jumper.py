#!/usr/bin/env python3
import subprocess
import sys
import json

def get_windows():
    """Fetches open windows and formats them with icon properties for Fuzzel."""
    try:
        result = subprocess.run(['niri', 'msg', '-j', 'windows'], capture_output=True, text=True, check=True)
    except FileNotFoundError:
        print("Error: 'niri' not found. Are you running Niri?")
        sys.exit(1)
    except subprocess.CalledProcessError as e:
        print(f"Error executing niri msg: {e}")
        sys.exit(1)

    windows_data = json.loads(result.stdout)

    # Dictionary to map the display string back to the window ID
    windows = {}
    # List to hold the formatted strings we actually feed into Fuzzel
    fuzzel_lines = []

    for win in windows_data:
        win_id = win.get('id')
        app_id = win.get('app_id', 'Unknown')
        title = win.get('title', 'Unknown')

        # The text the user will see and that Fuzzel will return
        display_str = f"[{app_id}] {title}"
        windows[display_str] = win_id

        # The text Fuzzel receives: "Display String\0icon\x1ficon-name"
        # \0 separates the visible text from the properties
        # \x1f separates the property key ('icon') from the value (app_id)
        fuzzel_lines.append(f"{display_str}\0icon\x1f{app_id}")

    return windows, fuzzel_lines

def main():
    windows, fuzzel_lines = get_windows()

    if not windows:
        print("No open windows found.")
        sys.exit(0)

    # Join the specially formatted lines with newlines
    fuzzel_input = '\n'.join(fuzzel_lines)

    try:
        # Fuzzel automatically parses the \0icon\x1f extensions in dmenu mode
        fuzzel_process = subprocess.run(
            ['fuzzel', '-d', '-p', 'Jump to window: '],
            input=fuzzel_input,
            capture_output=True,
            text=True
        )
    except FileNotFoundError:
        print("Error: 'fuzzel' is not installed.")
        sys.exit(1)

    # Fuzzel only returns the text before the \0, so we can match it cleanly
    selected = fuzzel_process.stdout.strip()

    if selected in windows:
        win_id = windows[selected]
        subprocess.run(['niri', 'msg', 'action', 'focus-window', '--id', str(win_id)])

if __name__ == '__main__':
    main()
