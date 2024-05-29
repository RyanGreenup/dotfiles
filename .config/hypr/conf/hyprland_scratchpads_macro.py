#!/usr/bin/env python3
# ~/.config/hypr/conf/hyprland_scratchpads_macro.py

from __future__ import annotations
from textwrap import dedent
import os
from copy import deepcopy

"""
This script build the hyprland_scratchpads.conf file.

This script was written as a python script / macro to reduce errors in the
file, which can be a pain as it updates live.
"""


class Key:
    def __init__(self, mod: list[str], key: str):
        self.mod = mod
        self.key = key

    def append_CTRL(self):
        self.mod.append("CTRL")

    def __str__(self):
        mod = " ".join(self.mod)
        return f"{mod}, {self.key}"

    @staticmethod
    def are_keys_unique(scratchpads: dict["str", Scratchpad]) -> bool:
        keys = [s.key for s in scratchpads.values()]
        return len(keys) == len(set(keys))


class Scratchpad:
    def __init__(
        self, wspace: str, cmd: list[str], key: Key, comment: str | None = None
    ):
        self.wspace = wspace
        self.cmd = " ".join(cmd)
        self.key = key
        self.comment = comment

    def __str__(self):
        comment = f"# {self.comment}" if self.comment else ""

        (move_key := deepcopy(self.key)).append_CTRL()
        # move_key = str(move_key)
        # key = str(self.key)
        scratchpad_cmd = f"""\
        {comment}
        $wspace = {self.wspace}
        workspace = special:$wspace, on-created-empty: {self.cmd}
        bind = {self.key}, togglespecialworkspace,        special:$wspace
        bind = {move_key}, movetoworkspace,         $wspace
        """

        return dedent(scratchpad_cmd)


def main():
    scratchpads = build_commands()
    write_commands(scratchpads)
    print(generate_commands(scratchpads))


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
        ["~/.config/hypr/open-things.sh", "agenda"],
        Key(["SUPER", "SHIFT"], "A"),
        "Org Mode Agenda",
    )

    scratchpads["notes"] = Scratchpad(
        "notes",
        ["~/.config/hypr/open-things.sh", "notes"],
        Key(["SUPER", "SHIFT"], "G"),
        "Open Notetaking Software",
    )

    scratchpads["Messages"] = Scratchpad(
        "messages",
        ["~/.config/hypr/open-things.sh", "messages"],
        Key(["SUPER", "SHIFT"], "M"),
        "Open Messages",
    )

    scratchpads["dokuwiki"] = Scratchpad(
        "dokuwiki",
        ["~/.config/hypr/open-things.sh", "dokuwiki"],
        Key(["SUPER", "SHIFT"], "F2"),
        "Open Dokuwiki",
    )

    return scratchpads


def write_commands(scratchpads: dict["str", Scratchpad]):
    HOME = os.getenv("HOME")
    assert HOME, "HOME not found"
    with open(f"{HOME}/.config/hypr/conf/hyprland_scratchpads.conf", "w") as f:
        f.write(generate_commands(scratchpads))


def generate_commands(
    scratchpads: dict["str", Scratchpad], allow_dup_keys=False
) -> str:
    sep = "\n\n"
    output = (
        "# This is a generated file\n"
        f"# See ~/.config/hypr/conf/hyprland_scratchpads_macro.py{sep}"
    )

    if not allow_dup_keys:
        assert Key.are_keys_unique(scratchpads), "Keys are not unique"

    output += "\n\n".join([str(s) for s in scratchpads.values()])

    return output


if __name__ == "__main__":
    main()
