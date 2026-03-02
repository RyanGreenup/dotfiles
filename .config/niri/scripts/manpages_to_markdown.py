#!/usr/bin/env python3
"""Convert swayfx man pages to GitHub-Flavored Markdown.

Reads the raw troff sources from the arch distrobox container, converts to
pandoc JSON AST, fixes empty table headers via pandoc_fix_table_headers,
then renders to GFM under docs/swayfx/.
"""

import json
import subprocess
import sys
from pathlib import Path

from pandoc_fix_table_headers import fix_table_headers

DOCS_DIR = Path(__file__).resolve().parent.parent / "docs"
CONTAINER = "arch"

PAGES = [
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
]


def distrobox_run(cmd: list[str], **kwargs) -> subprocess.CompletedProcess:
    return subprocess.run(
        ["distrobox", "enter", CONTAINER, "--"] + cmd,
        **kwargs,
    )


def convert_manpage(name: str, section: str, out_dir: Path) -> bool:
    """Fetch raw man source from distrobox, convert to markdown with pandoc."""
    # Locate the source file inside the container
    result = distrobox_run(
        ["man", "-w", section, name],
        capture_output=True, text=True,
    )
    if result.returncode != 0:
        return False

    man_path = result.stdout.strip()

    # Read raw troff source (gzipped) from distrobox
    zcat = distrobox_run(
        ["zcat", man_path],
        capture_output=True,
    )
    if zcat.returncode != 0:
        return False

    # troff -> JSON AST
    to_json = subprocess.run(
        ["pandoc", "-f", "man", "-t", "json", "--standalone"],
        input=zcat.stdout,
        capture_output=True,
    )
    if to_json.returncode != 0:
        print(f"    pandoc man->json failed: {to_json.stderr.decode()}",
              file=sys.stderr)
        return False

    # Fix empty table headers in the AST
    doc = json.loads(to_json.stdout)
    fix_table_headers(doc)

    # JSON AST -> GFM
    to_gfm = subprocess.run(
        ["pandoc", "-f", "json", "-t", "gfm", "--standalone"],
        input=json.dumps(doc),
        capture_output=True, text=True,
    )
    if to_gfm.returncode != 0:
        print(f"    pandoc json->gfm failed: {to_gfm.stderr}",
              file=sys.stderr)
        return False

    out_file = out_dir / f"{name}.{section}.md"
    out_file.write_text(to_gfm.stdout)
    return True


def main(
    pages: list[str] | None = None,
    out_dir: Path | None = None,
) -> None:
    pages = pages or PAGES
    out_dir = out_dir or DOCS_DIR / "swayfx"
    out_dir.mkdir(parents=True, exist_ok=True)

    for entry in pages:
        name, section = entry.rstrip(")").split("(")
        ok = convert_manpage(name, section, out_dir)
        status = "ok" if ok else "not found"
        print(f"  {entry:30s} {status}")

    print(f"\nMarkdown written to {out_dir}")


if __name__ == "__main__":
    main()
