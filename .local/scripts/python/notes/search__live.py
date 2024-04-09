#!/usr/bin/env python3
# Path: path/to/your_script.py
# -*- coding: utf-8 -*-


from utils import getch_unix, Key, keys
import os
from search import perform_query
import subprocess
from config import Config


keys = []


def main():
    conf = Config.default()
    old_dir = os.getcwd()
    os.chdir(conf.notes_dir)
    search_live(conf)
    os.chdir(old_dir)


def search_live(conf: Config):
    quit = False
    while not quit:
        try:
            c = getch_unix()
            if c == Key.ESCAPE:
                print("Quitting...")
                quit = True
                break
            elif c == Key.BACKSPACE:
                if len(keys) > 0:
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

                matches, content = perform_query(search_term, conf.search_cache_dir)
                # out = subprocess.run(["fd", search_term], stdout=subprocess.PIPE, text=True)
                # matches = out.stdout.split("\n")
                print("Search term: ", search_term, "\n\n")
                # for line in matches[:10]:
                #     print(line)
                N = min(10, len(matches))
                for line, cl in zip(matches[:N], content[:N]):
                    print(f"\033[1;34m{line}\033[0m")
                    for t in search_term.split(" "):
                        cl = cl.replace(t, "\033[1;31m" + t + "\033[0m")
                    cl = cl.replace("\n", " ")
                    cl = cl.replace("\t", " ")

                    print("\t >  " + cl[0:80])
                    print("\t >  " + cl[80:160])
                    print("\t >  " + cl[160:240] + "\n")
            else:
                print("No search term provided")
        except KeyboardInterrupt:
            print("Exiting...")
            break


if __name__ == '__main__':
    main()


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
