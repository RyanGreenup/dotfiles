#!/usr/bin/env python3
import subprocess
import sys
import json

def get_windows():
    """Fetches open windows using niri msg and formats them."""
    try:
        # Get the list of windows from Niri in JSON format
        result = subprocess.run(['niri', 'msg', '-j', 'windows'], capture_output=True, text=True, check=True)
    except FileNotFoundError:
        print("Error: 'niri' not found. Are you running Niri?")
        sys.exit(1)
    except subprocess.CalledProcessError as e:
        print(f"Error executing niri msg: {e}")
        sys.exit(1)

    windows_data = json.loads(result.stdout)
    windows = {}

    for win in windows_data:
        win_id = win.get('id')
        app_id = win.get('app_id', 'Unknown')
        title = win.get('title', 'Unknown')

        # Format the display string: [App ID] Window Title
        display_str = f"[{app_id}] {title}"

        # Map the exact display string to the Niri window ID
        windows[display_str] = win_id

    return windows

def main():
    windows = get_windows()

    if not windows:
        print("No open windows found.")
        sys.exit(0)

    # Prepare the newline-separated string to feed into wofi
    wofi_input = '\n'.join(windows.keys())

    try:
        # Call wofi in dmenu mode
        wofi_process = subprocess.run(
            ['wofi', '--show', 'dmenu', '-i', '-p', 'Jump to window:'],
            input=wofi_input,
            capture_output=True,
            text=True
        )
    except FileNotFoundError:
        print("Error: 'wofi' is not installed.")
        sys.exit(1)

    # Get the user's selection (strip removes the trailing newline)
    selected = wofi_process.stdout.strip()

    # If the user made a selection (didn't press Esc), focus the window
    if selected in windows:
        win_id = windows[selected]
        # Tell Niri to focus the window by its ID
        subprocess.run(['niri', 'msg', 'action', 'focus-window', '--id', str(win_id)])

if __name__ == '__main__':
    main()
