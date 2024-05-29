#!/usr/bin/env python3
# ~/.config/hypr/conf/hyprland_scratchpads_macro.py
from textwrap import dedent

"""
This script build the hyprland_scratchpads.conf file.

This script was written as a python script / macro to reduce errors in the
file, which can be a pain as it updates live.
"""

import os


class Key:
    def __init__(self, mod: list[str], key: str):
        self.mod = " ".join(mod)
        self.key = key

    def __str__(self):
        return f"{self.mod}, {self.key}"


class Scratchpad:
    def __init__(
        self, wspace: str, cmd: list[str], key: Key, comment: str | None = None
    ):
        self.wspace = wspace
        self.cmd = " ".join(cmd)
        self.key = str(key)
        self.comment = comment

    def __str__(self):
        comment = f"# {self.comment}" if self.comment else ""

        scratchpad_cmd = f"""\
        {comment}
        $wspace = {self.wspace}
        workspace = special:$wspace, on-created-empty: {self.cmd}
        bind = {self.key}, movetoworkspace, special:$wspace
        bind = {self.key}, togglespecialworkspace, $wspace
        """

        return dedent(scratchpad_cmd)


def generate_commands(scratchpads: dict["str", Scratchpad]) -> str:
    sep = "\n\n"
    output = (
        "# This is a generated file\n"
        f"# See ~/.config/hypr/conf/hyprland_scratchpads_macro.py{sep}"
    )

    output += "\n\n".join([str(s) for s in scratchpads.values()])

    return output


def write_commands(scratchpads: dict["str", Scratchpad]):
    HOME = os.getenv("HOME")
    assert HOME, "HOME not found"
    with open(f"{HOME}/.config/hypr/conf/hyprland_scratchpads.conf") as f:
        f.write(generate_commands(scratchpads))


def build_commands() -> dict["str", Scratchpad]:
    scratchpads = dict()

    scratchpads["terminal"] = Scratchpad(
        "scratch", ["$term"], Key(["SUPER"], "grave"), "Terminal Scratchpad"
    )

    scratchpads["flarum"] = Scratchpad(
        "flarum",
        ["~/.local/bin/qutebrowser", "http://flarum.eir"],
        Key(["SUPER"], "F1"),
        "Discussion Forums",
    )

    scratchpads["agenda"] = Scratchpad(
        "agenda",
        ["~/.config/hypr/open-things.sh" "agenda"],
        Key(["SUPER", "SHIFT"], "A"),
        "Org Mode Agenda",
    )

    scratchpads["notes"] = Scratchpad(
        "notes",
        ["~/.config/hypr/open-things.sh" "notes"],
        Key(["SUPER", "SHIFT"], "G"),
        "Open Notetaking Software",
    )

    scratchpads["Messages"] = Scratchpad(
        "messages",
        ["~/.config/hypr/open-things.sh" "messages"],
        Key(["SUPER", "SHIFT"], "M"),
        "Open Messages",
    )

    scratchpads["dokuwiki"] = Scratchpad(
        "dokuwiki",
        ["~/.config/hypr/open-things.sh" "dokuwiki"],
        Key(["SUPER", "SHIFT"], "D"),
        "Open Dokuwiki",
    )

    return scratchpads


def main():
    scratchpads = build_commands()
    write_commands(scratchpads)
    print(generate_commands(scratchpads))


if __name__ == "__main__":
    main()
