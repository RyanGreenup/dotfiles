#!/usr/bin/env python3
import os
import sys
import subprocess
import shutil

# Change current directory so find prints rel path
HOME = os.getenv("HOME")
assert HOME is not None
os.chdir(f"{HOME}/Notes/dokuwiki/config/dokuwiki/data/pages/")

# Construct the fzf cmd string
cmd_string = r"fd '\.txt' | fzf -m --preview 'bat {} -l mediawiki'"


# Check everything is installed
def check_installed(cmd):
    if not shutil.which(cmd):
        print(f"{cmd} is not installed", sys.stderr)
        # Don't exit, as we want to check all the commands
        # and push through if the user has an unusual setup


for cmd in ["fd", "fzf", "bat"]:
    check_installed(cmd)


# Execute the `fd | fzf`
process_output = subprocess.run(cmd_string, stdout=subprocess.PIPE, shell=True)

# If the output is empty or the return code is not 0, exit
empties = [None, b"", "", " "]
if process_output.stdout in empties or process_output.returncode != 0:
    sys.exit()

# Remove empty strings and split the output
files = process_output.stdout.strip().decode().split("\n")
files = [file for file in files if file != ""]

# Open the files in nvim
subprocess.run(["nvim", "-O", *files])
