#!/usr/bin/env python3

import subprocess
from subprocess import PIPE
import argparse


def main(args: argparse.Namespace):
    if not args.session:
        fzf_tmux_sessions()
    else:
        attach_to_tmux_session(args.session)


def attach_to_tmux_session(session_name: str):
    p = subprocess.run(
        ["tmux", "attach", "-t", session_name], stdout=PIPE, stderr=PIPE)
    out = p.stdout.decode('utf-8')
    if p.returncode != 0:
        print(f"Error: {p.returncode}")
        print(out)
        print(f"Unable to attach to session {session_name}. Creating...")
        start_tmux_session(session_name)


def start_tmux_session(session_name: str):
    if session_name not in get_tmux_session():
        p = subprocess.run(["tmux", "new", "-s", session_name])
        if p.returncode != 0:
            print(f"Error: {p.returncode}")
            print(f"Unable to create session {session_name}. Exiting.")
            print(p.stdout.decode('utf-8'))
            return
    else:
        print(f"Session {session_name} already exists. Attaching to it.")
        attach_to_tmux_session(session_name)
        return
    return


def get_tmux_session() -> list[str]:
    p = subprocess.run(["tmux", "ls"], stdout=PIPE)
    output = p.stdout.decode('utf-8')
    tmux_sessions = output.split("\n")
    tmux_sessions = [x.split(":")[0] for x in tmux_sessions if x]

    # Cut off the trailing -\d
    tmux_sessions_rev = [t[::-1] for t in tmux_sessions]
    tmux_sessions_rev = [
        t.split("-", 1)[1] if "-" in t else t for t in tmux_sessions_rev]
    tmux_sessions = [t[::-1] for t in tmux_sessions_rev]

    return tmux_sessions


def fzf_tmux_sessions():
    tmux_sessions = get_tmux_session()

    p = subprocess.run([
        "fzf", "--height", "30%",
        "--preview", "tmux capture-pane -p -t {}"],
        input=bytes("\n".join(tmux_sessions), 'utf-8'),
        stdout=PIPE)
    if p.returncode == 130:
        print("No session selected")
        return
    elif p.returncode != 0:
        print(p.returncode)
        print("Unable to get session selection. Exiting.")
        return
    selected_session = p.stdout.decode('utf-8').strip()

    # Attach to the selected session
    subprocess.run(["tmux", "attach", "-t", selected_session])


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Tmux session wrapper using fzf")
    parser.add_argument(
        "session", help=("The session to create or attach."
                         " If not provided, fzf will list them."),
        nargs="?", default=None, type=str)
    args = parser.parse_args()
    main(args)
