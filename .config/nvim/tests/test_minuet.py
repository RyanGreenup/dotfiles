"""Integration test: open Neovim in Kitty, trigger minuet completion, verify it streams in."""

import subprocess
import time
import sys

WINDOW_TITLE = "test-minuet"
MATCH = f"title:{WINDOW_TITLE}"
TEST_FILE = "/tmp/test_minuet.py"


def kitty(*args):
    return subprocess.run(
        ["kitty", "@", *args], capture_output=True, text=True, timeout=10
    )


def get_text():
    r = kitty("get-text", "--match", MATCH, "--extent", "screen")
    return r.stdout


def send(text):
    kitty("send-text", "--match", MATCH, text)


def wait_for(needle, timeout=15):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if needle in get_text():
            return True
        time.sleep(0.5)
    return False


def wait_for_gone(needle, timeout=30):
    """Wait for a string to disappear from the screen."""
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if needle not in get_text():
            return True
        time.sleep(0.5)
    return False


def get_messages():
    """Exit insert mode, run :messages, return screen content."""
    send("\x1b")
    time.sleep(0.3)
    send(":messages\n")
    time.sleep(1)
    return get_text()


def main():
    with open(TEST_FILE, "w") as f:
        f.write("import os\n\ndef fibonacci(n):\n    ")

    # Launch Neovim directly — API key is read from file, no env var needed
    kitty(
        "launch",
        "--type=window",
        "--title", WINDOW_TITLE,
        "--keep-focus",
        "nvim", TEST_FILE,
    )

    try:
        if not wait_for("fibonacci", timeout=20):
            print("FAIL: Neovim did not open the test file in time")
            return 1

        # Let plugins finish loading
        time.sleep(4)

        # Position cursor and enter insert mode
        send(":normal! 3G$\n")
        time.sleep(0.3)
        send("a\n    ")
        time.sleep(0.5)

        # Trigger minuet completion with Alt+y
        send("\x1by")

        # Wait for Loading indicator (confirms trigger fired)
        if not wait_for("Loading", timeout=5):
            print("FAIL: minuet did not trigger (no Loading indicator)")
            print("--- :messages ---")
            print(get_messages())
            return 1

        print("OK: minuet triggered, Loading... visible")

        # Wait for Loading to disappear (completion arrived or error)
        if not wait_for_gone("Loading", timeout=30):
            print("FAIL: stuck on Loading... — completion never arrived")
            print("--- :messages ---")
            print(get_messages())
            return 1

        print("OK: Loading disappeared")

        # Check for errors in :messages
        messages = get_messages()

        error_keywords = ["returns error", "unsupported_parameter", "invalid_api_key", "api_key"]
        errors = []
        for line in messages.splitlines():
            low = line.lower()
            if any(kw in low for kw in error_keywords):
                errors.append(line.strip())

        if errors:
            print("FAIL: API errors found:")
            for e in errors:
                print(f"  {e}")
            return 1

        print("PASS: minuet completion streamed successfully")
        return 0

    finally:
        kitty("close-window", "--match", MATCH)


if __name__ == "__main__":
    sys.exit(main())
