#!/usr/bin/env python3
import os
import sys
import subprocess

# Change current directory to the absolute path
os.chdir('/home/ryan/Notes/dokuwiki/config/dokuwiki/data/pages/')

# Construct the command string for the subprocess
cmd_string = r"fd '\.txt' | fzf -m --preview 'bat {} -l mediawiki'"

# Execute the `fd` and `fzf` commands and get the output
process_output = subprocess.run(
    cmd_string,
    stdout=subprocess.PIPE,
    shell=True
)

# If the output is empty or the return code is not 0, exit
if process_output.stdout in [None, b'', '', ' '] or process_output.returncode != 0:
    sys.exit()

files = process_output.stdout.decode().split('\n')


subprocess.run(["nvim", "-O", *files])
sys.exit(0)
