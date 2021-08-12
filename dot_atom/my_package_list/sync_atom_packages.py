#!/usr/bin/python3

import sys
import os

def main():
    if len(sys.argv) != 2:
        help_page()
    elif sys.argv[1] == "-i" or sys.argv[1] == "--install":
        os.system("apm install --packages-file ./atomPackages.txt")
    elif sys.argv[1] == "-w" or sys.argv[1] == "--write":
        os.system("apm list --installed --bare > atomPackages.txt")
    else:
        help_page()

def help_page():
    print("Usage: ", sys.argv[0], " [OPTION]")
    print("\n")
    print("  -w  --write     Write installed apm packages to atomPackages.txt")
    print("  -i  --install   Install packages saved in atomPackages.txt")
    print("\n")

main()
