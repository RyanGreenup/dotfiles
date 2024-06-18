#!/usr/bin/env python3
import sys
import os
import subprocess
from subprocess import run


def main():
    # Get the input file
    input = sys.argv[1]

    # Get the extension
    name, ext = os.path.splitext(input)

    bin = ext_map.get(ext, "nvim")

    print(f"Opening {input} with {bin}")

    try:
        run([bin, input])
    except FileNotFoundError as e:
        print("---")
        print(f"The Binary: `{bin}` not found, are you sure it's installed?")
        print("---")
        raise e





ext_map = {
    ".xlsx": "vd",
    ".duckdb": "vdsql",
    ".md": "nvim",
}


if __name__ == "__main__":
    main()
