#!/usr/bin/env python3
import os
import sys
import argparse


def main():
    parser = argparse.ArgumentParser(description="Find relative path")
    parser.add_argument(
        "--path", type=str, help="Absolute path to the file or directory"
    )
    parser.add_argument(
        "--start_directory", type=str, help="Starting directory for the relative path"
    )
    args = parser.parse_args()

    if not os.path.exists(args.path):
        print("The provided path does not exist.", sys.stderr)
        sys.exit(1)

    if not os.path.isdir(args.start_directory):
        print("The start directory does not exist or is not a directory.", sys.stderr)
        sys.exit(1)

    relative_path = os.path.relpath(args.path, args.start_directory)
    print(relative_path)


if __name__ == "__main__":
    main()
