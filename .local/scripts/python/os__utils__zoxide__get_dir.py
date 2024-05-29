#!/usr/bin/env python3
# Path: path/to/your_script.py
# -*- coding: utf-8 -*-

"""
Your module-level docstring explaining this script's primary function or role.
Add any relevant usage instructions and notes about expected inputs/outputs.
"""

import argparse
import subprocess
# TODO this import breaks it because notes.utils imports
# config which is under notes
# TO fix this make two notes/utils.py, one that requires config
# and the other that does not, one could be called
# notes/utils.py
# and the other notes/utils_no_config.py
from notes.utils import gui_select, fzf_select
from subprocess import PIPE


def main(gui: bool = False):
    """
    The core function that encapsulates all tasks performed by this script.
    Args can be parsed during runtime using the argparse module.
    """
    out = subprocess.run(["zoxide", "query", "-l"],
                         stdout=PIPE,
                         check=True,
                         text=True)
    out = out.stdout.strip().splitlines()
    if gui:
        print(gui_select(out))
    else:
        print(fzf_select(out))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Add a description for your program")
    parser.add_argument(
        "--gui",
        "-g",
        action="store_true",
        help="Use a GUI instead of a fzf"

    )
    args = parser.parse_args()
    main(args.gui)
