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

Free bindings that are nice:

    - s-C-m
    - s-a
"""


class Key:
    def __init__(self, mod: list[str], key: str):
        self.mod = mod
        self.key = key

    def append_SHIFT(self):
        self.mod.append("SHIFT")

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

        (move_key := deepcopy(self.key)).append_SHIFT()
        # move_key = str(move_key)
        # key = str(self.key)
        scratchpad_cmd = f"""\
        {comment}
        $wspace = {self.wspace}
        workspace = special:$wspace, on-created-empty: {self.cmd}
        bind = {self.key}, togglespecialworkspace, $wspace
        bind = {move_key}, movetoworkspace, special:$wspace
        """

        return dedent(scratchpad_cmd)

    def summary(self):
        output = f"""\
        {self.key}: {self.comment}
        """

        return dedent(output)



def main():
    scratchpads = build_commands()
    write_commands(scratchpads)
    print(generate_commands(scratchpads))
    print(print_summarize_commands(scratchpads))


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
        Key(["SUPER", "CTRL"], "o"),
        "Org Mode Agenda",
    )

    scratchpads["notes_write"] = Scratchpad(
        "notes_write",
        ["~/.config/hypr/open-things.sh", "notes_write"],
        Key(["SUPER"], "g"),
        "Open Notetaking Software",
    )

    scratchpads["notes_read"] = Scratchpad(
        "notes_read",
        ["~/.config/hypr/open-things.sh", "notes_read"],
        Key(["SUPER", "CTRL"], "g"),
        "Open Notetaking Software",
    )

    scratchpads["Messages"] = Scratchpad(
        "messages",
        ["~/.config/hypr/open-things.sh", "messages"],
        Key(["SUPER"], "y"),
        "Open Messages",
    )

    scratchpads["dokuwiki"] = Scratchpad(
        "dokuwiki",
        ["~/.config/hypr/open-things.sh", "dokuwiki"],
        Key(["SUPER"], "F2"),
        "Open Dokuwiki",
    )

    scratchpads["open-web-ui"] = Scratchpad(
        "open-web-ui",
        ["distrobox-enter", "-n", "arch", "--", "/usr/bin/chromium", "http://ai.vale"],
        Key(["SUPER"], "F6"),
        "Open Web UI",
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

def print_summarize_commands( scratchpads: dict["str", Scratchpad]):
    for k,v in scratchpads.items():
        print(f"{k:<12} {v.key}")


if __name__ == "__main__":
    main()
