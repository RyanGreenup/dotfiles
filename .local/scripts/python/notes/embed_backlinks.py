#!/usr/bin/env python

import typer
import os
from typing import Annotated
from pathlib import Path, PurePath
import re
from re import Pattern
from pprint import pprint
import sys
from enum import Enum
from dataclasses import dataclass

# TODO add definition links


@dataclass
class Config:
    BL_START: str
    BL_END: str


def main(
    notes_dir: Path,
    remove: Annotated[bool, typer.Argument(help="Only Remove the backlinks")] = False,
):
    os.chdir(notes_dir)
    config = Config(
        BL_START="<!-- start_backlinks -->\n", BL_END="<!-- end_backlinks -->\n"
    )
    d = backlinks_dir(notes_dir)
    for file, bl in d.items():
        clear_backlinks_section(Path(file))
        if remove:
            continue
        try:
            file = notes_dir.joinpath(file)
            bl = [str(notes_dir.joinpath(b)) for b in bl]
            bl = [os.path.relpath(b, file.parent) for b in bl]
            add_backlinks_section(Path(file), bl, config)
        except Exception as e:
            print(e, file=sys.stderr)


def format_title(title: str) -> str:
    return title.replace("_", " / ").replace("-", " ").replace(".md", "").title()


def add_backlinks_section(file_path: Path, backlinks: list[str], config: Config):
    # First remove the backlinks
    clear_backlinks_section(file_path)

    # Then add the backlinks
    lines = file_path.open().readlines()
    backlinks_str = "\n".join([f" - [{format_title(b)}]({b})\n" for b in backlinks])
    lines.append("\n" + config.BL_START)
    lines.append("## Backlinks\n")
    lines.append(backlinks_str + "\n")
    lines.append(config.BL_END)
    file_path.open("w").writelines(lines)


def clear_backlinks_section(file_path: Path):
    lines = file_path.open().readlines()
    new_lines = []
    keep = True
    for line in lines:
        match line:
            case "<!-- start_backlinks -->\n":
                keep = False
            case "<!-- end_backlinks -->\n":
                keep = True
                continue
        if keep:
            new_lines.append(line)
    file_path.open("w").writelines(new_lines)


clear_backlinks_section(Path("/tmp/file.md"))


class MDPattern:
    def __init__(self, pattern: str, includes_ext: bool = True):
        self.pattern = re.compile(pattern)
        self.includes_ext = includes_ext

    # TODO make DRY
    def match(self, file_text: str, dir: Path, file_path: Path) -> list[str]:
        if self.includes_ext:
            links = [
                file_path.parent.joinpath(m[1]).relative_to(dir)
                for m in re.findall(self.pattern, file_text)
                if ".md" in m[1] and not m[1].startswith("/")
            ]
            links = [
                str(link)
                for link in links
                if dir.joinpath(link).exists() and link.is_file()
            ]
            return links
        else:
            links = [
                file_path.parent.joinpath(m[1]).relative_to(dir)
                for m in re.findall(self.pattern, file_text)
                if not m[1].startswith("/")
            ]
            links = [str(link) + ".md" for link in links if dir.joinpath(link).exists()]
        return links


def backlinks_dir(notes_dir: Path) -> dict[str, list[str]]:
    dir: Path = Path(notes_dir)
    assert dir.is_dir(), "Directory does not exist"

    md_link_ptrn = r"\[([^]]+)\]\(([^)]+)\)"
    wiki_link_ext_ptrn = r"\[\[([^]|]+)(?:\|([^]]+))?\.md\]\]"
    wiki_link_ptrn = r"\[\[([^]|]+)(?:\|([^]]+))?\]\]"
    links_dict: dict[str, list[str]] = dict()

    patterns = [
        MDPattern(md_link_ptrn),
        MDPattern(wiki_link_ext_ptrn),
        MDPattern(wiki_link_ptrn, False),
    ]

    patterns = [MDPattern(md_link_ptrn)]

    # TODO wiki_link pattenrs needs to ignore missing ".md" and then add it back
    # need to rethink logic here, probably clean dict after all links are found
    # TODO this also doesn't cover definition links either :(
    for root, _, files in os.walk(dir):
        for file in files:
            if file.endswith(".md"):
                file_path = Path(os.path.join(root, file))
                file_text = open(file_path).read()
                for ptn in patterns:
                    links = ptn.match(file_text, dir, file_path)
                    print(links)
                    for li in links:
                        if li not in links_dict:
                            links_dict[li] = []  # pyright:ignore
                        links_dict[li].append(str(file_path.relative_to(dir)))
    return links_dict


def get_links(
    ptn: Pattern,
    file_text: str,
    file_path: Path,
    dir: Path,
    pattern_includes_ext: bool = False,
) -> list[str]:
    """
    Get all the links from the text that match the pattern

    Args:

    ptn: Pattern - The pattern to match
    text: str - The text to search for the pattern
    pattern_includes_ext: bool - Add the ".md" extension back to the match
                                 e.g. [[foo]] -> [[foo.md]]
    dir: Path - The directory containing the files, e.g. ~/Notes/slipbox
    """
    if pattern_includes_ext:
        # Get the matches
        links = [
            file_path.parent.joinpath(m[1]).relative_to(dir)
            for m in re.findall(ptn, file_text)
            if ".md" in m[1] and not m[1].startswith("/")
        ]
    else:
        # Get the matches
        links = [
            file_path.parent.joinpath(m[1]).relative_to(dir)
            for m in re.findall(ptn, file_text)
            if not m[1].startswith("/")
        ]
    links = [link for link in links if link.is_file()]
    return [str(link) for link in links]


if __name__ == "__main__":
    typer.run(main)
