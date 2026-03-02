#!/usr/bin/env python3
"""Export sway and swayfx man pages to plain text under docs/."""

import os
import subprocess
from pathlib import Path

DOCS_DIR = Path(__file__).resolve().parent.parent / "docs"

GROUPS = {
    "sway": [
        "sway(1)",
        "sway(5)",
        "sway-bar(5)",
        "sway-input(5)",
        "sway-output(5)",
        "sway-ipc(7)",
        "swaymsg(1)",
        "swaynag(1)",
        "swaynag(5)",
        "swaybar-protocol(7)",
    ],
    "swayfx": [
        "swayfx(1)",
        "swayfx(5)",
    ],
}


def export_manpage(name: str, section: str, out_dir: Path) -> bool:
    out_file = out_dir / f"{name}.{section}.txt"
    try:
        result = subprocess.run(
            ["man", section, name],
            capture_output=True,
            text=True,
            env={**os.environ, "MANWIDTH": "80", "COLUMNS": "80"},
        )
        if result.returncode != 0:
            return False
        # Strip backspace-based formatting left by some man implementations
        text = result.stdout
        out_file.write_text(text)
        return True
    except FileNotFoundError:
        return False


def main() -> None:
    for group, pages in GROUPS.items():
        out_dir = DOCS_DIR / group
        out_dir.mkdir(parents=True, exist_ok=True)
        for entry in pages:
            # parse "name(section)"
            name, section = entry.rstrip(")").split("(")
            ok = export_manpage(name, section, out_dir)
            status = "ok" if ok else "not found"
            print(f"  {entry:30s} {status}")

    print(f"\nDocs written to {DOCS_DIR}")


if __name__ == "__main__":
    main()
