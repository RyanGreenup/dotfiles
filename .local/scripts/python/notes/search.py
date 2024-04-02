#!/usr/bin/env python3
# Path: path/to/your_script.py
# -*- coding: utf-8 -*-


import tempfile
import argparse
import json
import subprocess
from subprocess import PIPE
from utils import sk_cmd
import os
import sys
import shutil

from config import Config
from utils import get_files
config = Config.default()


def main(
    query: str,
    notes_dir: str,
        editor: str,
        cache_dir: str,
        reindex: bool = False,
        context: bool = False,
        fzf: bool = False
) -> None:
    if reindex:
        index_tantivy(notes_dir, cache_dir)
    else:
        if not is_tantivy_init(cache_dir):
            init_tantivy(cache_dir)
            index_tantivy(notes_dir, cache_dir)

    matches, content = perform_query(query, cache_dir)
    if fzf:
        _ = query
        new_matches = sk_cmd(notes_dir, preview=True)
        new_content = []
        for i, m in enumerate(matches):
            if m in new_matches:
                new_content.append(content[i])
        matches = new_matches
        content = new_content
        if editor:
            os.chdir(notes_dir)
            subprocess.run([editor] + matches)
            return
    elif context:
        context_print(matches, content)
    else:
        print("\n".join(matches))


def context_print(matches: list[str], contents: list[str]) -> None:
    for match, content in zip(matches, contents):
        print(match)
        print("\n")
        print(" >  " + content[0:80])
        # with open(match, 'r') as f:
        #     context = f.read()[:(40*4)]
        #     context = ["  >  " + line for line in context.splitlines()]
        #     context = "\n".join(context)
        #     # context = context.replace("\n", " ")
        #     # # Add a new line every 80
        #     # context = "\n".join([context[i:i+80]
        #     #                     for i in range(0, len(context), 80)])
        #     print(context)
        print("\n")


def perform_query(term: str, cache_dir: str) -> tuple[list[str], list[str]]:
    """Perform a tantivy query which is basically:

        ```sh
        tantivy search - i ./slipbox_index \
                - -query {term} |\
                    jq '.path[]' |\
                    tr - d '"'
        ```"""
    out = subprocess.run(["tantivy", "search", "-i",
                         cache_dir, "--query", term],
                         text=True,
                         check=True,
                         stdout=PIPE)
    # The output is jsonlines
    out_json_lines = out.stdout
    # So split them
    out_json_list = out_json_lines.splitlines()
    # Grab each one as a dictionary
    out_dicts = [json.loads(d) for d in out_json_list]
    # This dict has content and path, pull out path
    paths = [doc['path'] for doc in out_dicts]
    # The path is a list of length 1, so pull flatten it
    paths = [p[0] for p in paths if len(p) >= 1]

    # Same idea for content
    contents = [doc['content'] for doc in out_dicts]
    contents = [p[0] for p in contents if len(p) >= 1]

    return paths, contents


# TODO double negative bad form
def is_tantivy_init(cache_dir: str = config.search_cache_dir) -> bool:
    """Check if the tantivy index is empty which implies not initialized
    """
    # Note the meta.json only exists if the directtory is already indexed
    # Check if the directory exists
    if not os.path.exists(cache_dir):
        return False
    # Check if the directory is non-empty
    elif len(os.listdir(cache_dir)) < 1:
        return False
    # Try to open the directory as an index
    elif 0 != subprocess.run(
            ["tantivy", "inspect", "-i", cache_dir],
            stdout=subprocess.PIPE, check=False).returncode:
        return False
    # If not assume all is well
    else:
        return True


def index_tantivy(notes_dir: str,
                  cache_dir: str,
                  remove_cache_file: bool = True):
    if not is_tantivy_init(cache_dir):
        print(f"Tantivy is not correctly initialized under {cache_dir}, "
              "the meta.json is missing. Re-initialize and try again",
              file=sys.stderr)
        raise Exception("Missing Tantivy Index")
    cache_file = tempfile.mktemp(suffix=".jsonl")
    build_notes_dict(notes_dir, cache_file)
    subprocess.run(["tantivy", "index", "--index", cache_dir,
                   "--file", cache_file], check=True)
    if remove_cache_file:
        os.remove(cache_file)  # Remove for privacy


def init_tantivy(cache_dir: str = config.search_cache_dir,
                 clobber: bool = False):
    print("Building the Tantivy Index")
    if clobber and os.path.exists(cache_dir):
        try:
            # Remove all directory contents
            shutil.rmtree(cache_dir)
        except Exception:
            pass
    else:
        print("Not removing old index")
        if is_tantivy_init(cache_dir):
            raise Exception(("Tantivy already initialized, "
                            "try again with --reindex"))
    print("Creating Tantivy Index, define the schema with:")
    print("")
    print('"path":    Text')
    print('"content": Text')
    print("")
    print("Everything else should be 'Y', [6 of them]")
    subprocess.run(["tantivy", "new", "-i", cache_dir], check=True)


def build_notes_dict(notes_dir: str,
                     file_location: str = config.search_cache_file) -> None:
    files = get_files(notes_dir, relative=False)

    def build_json_line(path: str, content: str) -> dict[str, str]:
        return {'path': path, 'content': content}

    jsonlines: list[dict[str, str]] = []
    for file in files:
        try:
            with open(file, 'r') as f:
                content = f.read()
                content = content.lower()
                for token in ['\t', '\n', '.', ':']:
                    content = content.replace(token, ' ')
                jsonlines.append(build_json_line(file, content))
        except Exception as e:
            print(e, file=sys.stderr)
            continue

    with open(file_location, 'w') as f:
        for line in jsonlines:
            json.dump(line, f)
            f.write("\n")


if __name__ == "__main__":
    config = Config.default()
    parser = argparse.ArgumentParser(
        description="Search Notes and create an index if needed")
    parser.add_argument(
        "--cache_dir",
        type=str, help="Index Directory for Tantivy",
        default=config.search_cache_dir
    )

    parser.add_argument(
        "--notes_dir",
        type=str, help="Notes Directory",
        default=config.notes_dir
    )

    # create sub-parser
    commands = parser.add_subparsers(help='sub-command help', dest='command')
    # create the parser for the "ahoy" sub-command
    parser_reindex = commands.add_parser(
        'reindex', help='Re index Notes')
    parser_init = commands.add_parser('init', help='Initialize Search Index')
    parser_search = commands.add_parser(
        'search', help='Initialize Search Index')

    parser_search.add_argument(
        "query",
        help="The Search query"
    )

    parser_search.add_argument(
        "--fzf",
        action='store_true',
        help="Use skim to search"
        " (use C-q to switch from search command to filter)"
    )

    parser_search.add_argument(
        "--editor",
        "-e",
        type=str, help="Search the notes and create the index if necessary",
        default=config.editor
    )

    args = parser.parse_args()
    match args.command:
        case "reindex":
            index_tantivy(args.notes_dir, args.cache_dir)
        case "init":
            init_tantivy(args.cache_dir, clobber=True)
            index_tantivy(args.notes_dir, args.cache_dir)
        case "search":
            if args.fzf:
                main("", args.notes_dir, args.editor,
                     args.cache_dir, fzf=True)
            else:
                main(args.query, args.notes_dir, args.editor, args.cache_dir)
