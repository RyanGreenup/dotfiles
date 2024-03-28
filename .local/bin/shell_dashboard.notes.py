#!/usr/bin/env python3

import sys
import os
import subprocess


HOME = os.getenv("HOME")
assert HOME, "HOME not set"
NOTES_DIR = f"{HOME}/Notes/slipbox"
THIS_FILE = os.path.realpath(__file__)
os.chdir(os.environ['HOME'])


def getch_unix():
    os.system('stty raw -echo')
    char = sys.stdin.read(1)
    os.system('stty -raw echo')
    return char


def main():
    run()

    return 0


def print_keys():
    s = ""
    with open(THIS_FILE, 'r') as f:
        printQ = False
        for line in f:
            if line == """# BEGIN_PRINT\n""":
                printQ = True
                continue
            elif line == """# END_PRINT\n""":
                printQ = False
                continue
            if printQ:
                s += line.replace('case ', '⌨️ ')
    os.system(f"echo '{s}' | bat --paging=never -l python")
    os.system("exa -lG")
    os.system("pwd")


def doit(s: str):
    os.system(s)
    os.system('clear')
    run()


def edit(f: str):
    editor = os.environ['EDITOR']
    doit(f"{editor} {f}")


def change_dir():
    # create first process
    p1 = subprocess.Popen(["fd", "-t", "d"], stdout=subprocess.PIPE)
    # pipe output into second process
    p2 = subprocess.Popen(
        ["fzf"], stdin=p1.stdout, stdout=subprocess.PIPE)

    stdout, stderr = p2.communicate()
    dir = stdout.decode('utf-8').rstrip()
    os.system(f"ls {dir}")

    change_to(dir)


def change_to(dir: str):
    os.chdir(dir)
    run()


def list_dir():
    os.system("clear")
    os.system("exa -l")
    run()


def rerun():
    os.system('clear')
    run()

def run():
    # TODO Should I start from file?
    # os.chdir(os.path.dirname(os.path.realpath(__file__)))
    print_keys()
    key = getch_unix()
# BEGIN_PRINT
    match key:
        case 'q':
            sys.exit(0)
        case 'l':
            print("TODO")
            doit("fd")
        case 'b':
            doit("broot")
        case 'l':
            list_dir()
        case 'e':
            match getch_unix():
                case 'f':
                    r = "~/.config/fish/config"
                    edit(f"-o {r}.fish {r}.org")
                case 'h':
                    edit("~/.config/hypr/hyprland.conf")
                case 'd':
                    edit(
                        "/home/ryan/Studies/programming/rust/shell_dispatcher/src/main.py")
                case _:
                    rerun()
        case 'c':
            match getch_unix():
                case 'd':
                    change_dir()
                case '.':
                    change_to("..")
                case '.':
                    change_to("h")
                case _:
                    rerun()
        case 'f':
            doit("ranger")
        case 'g':
            doit("gitui")
        case 's':
            doit("fish")
        case 'p':
            doit("workdispatch open")
        case 'z':
            doit("eval $(zoxide init bash); zi")
        case 'd':
            doit("gitui -w ~ -d ~/.local/share/dotfiles")
            doit("firefox https://www.datacamp.com/")
        case _:
            rerun()
# END_PRINT


if __name__ == '__main__':
    sys.exit(main())
