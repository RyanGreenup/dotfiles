#!/usr/bin/env python3
# Path: path/to/your_script.py
# -*- coding: utf-8 -*-


from utils import getch_unix, Key, keys
import os
import subprocess


keys = []


def main():
    print(getch_unix())
    # search_live()


def search_live():
    while True:
        try:
            # print("       <--------------  Search String", end="")
            c = getch_unix()
            if c == Key.ESCAPE:
                print("Quitting...")
                break
            elif c == Key.BACKSPACE:
                keys.pop()
            elif c == Key.SPACE or c == Key.TAB:
                keys.append(" ")
            else:
                keys.append(c)
            # print("\r > " + "".join(keys) + " " *
            #       10 + "<----- Search Term", end="")
            # print("Searching...")
            os.system("clear")
            if len(keys) > 0:
                search_term = "".join(keys)
                # search_term = search_term.replace(" ", ".*")
                out = subprocess.run(
                    ["note_taking", "-d", "/home/ryan/Notes/slipbox", "search",  search_term], stdout=subprocess.PIPE, text=True)
                out = out.stdout.split("\n")
                print("Search term: ", search_term, "\n\n")
                for line in out[:10]:
                    print_context(line)
            else:
                print("No search term provided")
        except KeyboardInterrupt:
            print("Exiting...")
            break


def print_context(file: str):
    """Open a file and print the title and the first 4 lines of the file"""
    try:
        with open(file, "r") as f:
            lines = f.readlines()[0:4]
            print("# " + file + "\n\n")
            for line in lines:
                print(line, end="")
    except FileNotFoundError:
        print("ﰸ" + file)


if __name__ == '__main__':
    main()
