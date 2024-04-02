#!/usr/bin/env python3

import functools
import sys
import os
import subprocess
import tempfile

import pyperclip
import find
import search
import make_link
import backlinks
from config import Config
import argparse
from pprint import pprint

from utils import fzf_select, gui_select


HALT = False  # Used to not rerun the recursive cases
HOME = os.getenv("HOME")
assert HOME, "HOME not set"
THIS_FILE = os.path.realpath(__file__)
SCRIPT_DIR = os.path.dirname(THIS_FILE)
os.chdir(os.environ['HOME'])


def getch_unix():
    os.system('stty raw -echo')
    char = sys.stdin.read(1)
    os.system('stty -raw echo')
    return char


def main(notes_dir: str, editor: str, gui: bool = False) -> None:
    c = Config.default()
    os.chdir(notes_dir)

    def rerun():
        os.system('clear')
        run()

    def doit(s: list[str]):
        print("Running: ", " ".join(s))
        try:
            subprocess.run(s, check=True)
        except Exception as e:
            print(e, file=sys.stderr)
        rerun()

    def do_one(s: list[str]):
        for cmd in s:
            print("Running: ", cmd)
            try:
                subprocess.run([cmd], check=True)
                break
            except Exception as e:
                print(e, file=sys.stderr)

    def edit(f: str):
        doit([editor, f])

    def change_dir():
        # create first process
        p1 = subprocess.Popen(["fd", "-t", "d"], stdout=subprocess.PIPE)
        # pipe output into second process
        p2 = subprocess.Popen(
            ["fzf"], stdin=p1.stdout, stdout=subprocess.PIPE)

        stdout, stderr = p2.communicate()
        dir = stdout.decode('utf-8').rstrip()
        # os.system(f"ls {dir}")

        change_to(dir)

    def change_to(dir: str):
        os.chdir(dir)
        # os.system(f"ls {dir}")
        print(os.getcwd() + ":")
        print("\t\t -->: ", end="")
        print(os.listdir())
        run()

    # TODO can we cache the stdout
    log: list[str] = []

    def dont_panic(func):
        """
        Function decorator that wraps the function call in a try/except block.
        """
        # Preserve the original function's signature using functools.wraps
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            try:
                # We attempt to execute the function as normal
                def new_func(*args, **kwargs):
                    func(*args, **kwargs)
                    rerun()
                return new_func(*args, **kwargs)
            except Exception as e:
                # Here, we handle any exceptions that may have occurred
                print(f"An exception occurred: {e}", file=sys.stderr)
                rerun()
        return wrapper

    @dont_panic
    def fzf_search_notes():
        search.main("", notes_dir, editor, c.search_cache_dir, fzf=True)

    @dont_panic
    def find_notes():
        find.main(notes_dir, editor, gui)

    def run():
        # TODO Should I start from file?
        # os.chdir(os.path.dirname(os.path.realpath(__file__)))
        print_keys()
# BEGIN_PRINT
        match getch_unix():
            case 'q':
                os.system('clear')
                sys.exit(0)
            case 'f':
                find_notes()
            case 'b':
                doit(["broot"])
            case 's':
                fzf_search_notes()
            case 'm':
                doit([os.path.join(SCRIPT_DIR, "search__semantic.py")])
            case 'l':
                make_link.main(notes_dir)
            case 'v':
                backlinks.main(pyperclip.paste(), notes_dir, editor, False)
            case 't':
                show_menu("t")
                match getch_unix():
                    case 'R':
                        search.init_tantivy(c.search_cache_dir)
                        search.index_tantivy(notes_dir, c.search_cache_dir)
                    case 'r':
                        search.index_tantivy(notes_dir, c.search_cache_dir)
                        rerun()
                    case 'd':
                        edit(__file__)
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
            case 'r':
                doit(["ranger"])
            case 'g':
                doit(["gitui"])
            case 's':
                doit(["fish"])
            case 'p':
                do_one(["xonsh", "ptpython", "ipython", "python"])
            case 'y':
                doit([editor, make_python_file()])
            case 'z':
                todo("fix ~/.local/scripts/python/os__utils__zoxide__get_dir.py")
            case _:
                rerun()
# END_PRINT

    run()

def make_python_file() -> str:
    file = tempfile.mktemp(suffix=".py")
    with open(file, "w") as f:
        f.write("#!/usr/bin/python3\n")
        f.write("import os\n")
        f.write(f"os.chdir('{os.getcwd()}')\n")
    return file


def print_keys():
    break_line = "---------------------\n"
    s = "\n"
    s += break_line
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
                if "try:" in line:
                    continue
    s += "\n" + break_line
    try:
        subprocess.run(["bat", "--style=snip", "--paging=never", "-l",
                       "python"], input=bytes(s, 'utf-8'))
    except Exception as e:
        print(e, file=sys.stderr)
        print(s)
    # os.system(f"echo '{s}' | bat --paging=never -l python")
    # os.system("exa -lG")
    # os.system("pwd")


def list_dir():
    os.system("clear")
    os.system("exa -l")
    run()


def todo(s: str):
    print("TODO: ", s)


# def find_notes():
#     fd_cmd = f"fd -t f '\.org$|\.md$|\.txt$' {NOTES_DIR}"
#     sk_cmd = ("""sk --ansi -m """
#               """--preview 'bat --style snip {} 2> /dev/null --color=always'""")
#
#     cmd = f"{fd_cmd} | {sk_cmd}"
#     files = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE)
#     files = files.stdout.splitlines()
#     subprocess.run(["codium", *files])


def show_menu(s: str):
    print(f"----> {s}")


def search_notes():
    cmd = "sk -m -i -c note_taking search -d " + NOTES_DIR + "{} --preview echo {+}"
    search_cmd = f"note_taking search -d {NOTES_DIR}" + " {} "
    # search_cmd = "echo {}"
    preview_cmd = "bat --color=always " + NOTES_DIR + "/{+}"
    cmd = f"sk -m -i -c '{search_cmd}' --preview '{preview_cmd}'"
    files = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, text=True)
    files = files.stdout.splitlines()
    files = [os.path.join(NOTES_DIR, f) for f in files]
    print(files)
    subprocess.run(["codium", *files])


if __name__ == "__main__":
    config = Config.default()
    parser = argparse.ArgumentParser(description="Find a Note with fzf")
    parser.add_argument(
        "--editor",
        type=str, help="Editor to open for the new note",
        default=config.editor
    )
    parser.add_argument(
        "--notes_dir",
        type=str, help="Notes Directory",
        default=config.notes_dir
    )

    parser.add_argument(
        "--gui",
        "-g",
        action="store_true",
        default=False,
        help="Notes Directory",
    )

    args = parser.parse_args()

    main(args.notes_dir, args.editor, args.gui)
